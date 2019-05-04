//
//  LearningCardView.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/5/1.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire
import WebKit
import AVFoundation

class LearningCardView: UIView, UITableViewDataSource, UIGestureRecognizerDelegate, UITableViewDelegate {
    
    let cornerRadius: CGFloat = 24.0
    
    var word: Word? = nil {
        didSet {
            isFaceUp = true
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    var similarWords = [Word]()
    var html: String?
    var css: String?
    
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    var player: AVAudioPlayer? = nil
    
    var similarWordTableView = UITableView()

    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 2
        self.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = cornerRadius
        
        if !isFaceUp {
            getDetail(word: word!.name)
        } else {
            getSimilarWords(word: word!.name)
        }
    }
    
    func updateUI() {
        if !isFaceUp {
            self.clearAll()
            let wordDetailWebView = WKWebView()
            wordDetailWebView.scrollView.showsHorizontalScrollIndicator = false
            self.addSubview(wordDetailWebView)
            wordDetailWebView.frame = self.bounds
            if let html = html, let css = css {
                wordDetailWebView.loadHTMLString("<p style='padding-top:16px;'></p>"+css+html, baseURL: nil)
            }
            // 右上角翻转按钮
            let flipBtn = UIButton(frame: CGRect(x: self.bounds.maxX - 36.0 , y: 6.0, width: 20, height: 20))
            flipBtn.setImage(UIImage(named:"flip"), for: .normal)
            flipBtn.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.flipCard))
            flipBtn.addGestureRecognizer(tapGesture)
            
            wordDetailWebView.scrollView.addSubview(flipBtn)
        } else {
            self.clearAll()
            let wordLabel = UILabel(frame: CGRect(x: 0, y: 48, width: self.bounds.maxX, height: 64))
            wordLabel.numberOfLines = 0
            wordLabel.text = word?.name
            wordLabel.textAlignment = .center
            wordLabel.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            wordLabel.font = .boldSystemFont(ofSize: 32)
            
            // 英式发音按钮 btn宽度小于60不显示文字(坑
            let britishEngBtn: UIButton = UIButton(frame: CGRect(x: 0, y: 108, width: self.bounds.maxX, height: 24))
            britishEngBtn.setImage(UIImage.init(imageLiteralResourceName: "horn"), for: .normal)
            britishEngBtn.imageView?.contentMode = .scaleAspectFit
            britishEngBtn.setTitle(String("  /\(word!.pronounce)/"), for: .normal)
            britishEngBtn.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
            britishEngBtn.addTarget(self, action: #selector(self.clickToPlaySound(_:)), for: UIControl.Event.touchUpInside)
            
            self.addSubview(britishEngBtn)
            self.addSubview(wordLabel)
            
            // 添加手势
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.flipCard))
            tapGesture.delegate = self
            self.addGestureRecognizer(tapGesture)
            
            // 相似单词
            if similarWords.count > 0 {
                let similarLabel = UILabel(frame: CGRect(x: 16, y: 208, width: self.bounds.maxX - 16, height: 32))
                similarLabel.numberOfLines = 0
                similarLabel.text = "相似单词"
                similarLabel.textAlignment = .left
                similarLabel.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                similarLabel.font = .boldSystemFont(ofSize: 16)
                self.addSubview(similarLabel)
            
                // 创建similarWordTableView
                similarWordTableView = UITableView(frame: CGRect(x: 0, y: 240, width: self.bounds.maxX, height: 180), style:.plain)
                similarWordTableView.dataSource = self
                similarWordTableView.delegate = self
                // 注册cell
                similarWordTableView.register(UINib(nibName:"WordCell", bundle:nil),forCellReuseIdentifier:"WordCell")
                // 设置
                similarWordTableView.tableFooterView = UIView()
                similarWordTableView.separatorStyle = .none
                similarWordTableView.isScrollEnabled = false
                self.addSubview(similarWordTableView)
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return similarWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let word = similarWords[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        
        if let wordCell = cell as? WordCell {
            wordCell.word = word
        }
        
        return cell
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: similarWordTableView))! {
            return false
        }
        return true
    }
    
    // 返回时取消选中
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewController()?.performSegue(withIdentifier: "showDetail", sender: tableView)
        similarWordTableView.deselectRow(at: indexPath, animated: true)
    }
    
    // 翻转动画
    @objc func flipCard(_ recognizer: UITapGestureRecognizer){
        switch recognizer.state {
            case .ended:
                UIView.transition(
                    with: self,
                    duration: 0.5,
                    options: [.transitionFlipFromLeft],
                    animations: {
                        self.isFaceUp = !self.isFaceUp
                })
            default:
                break
        }
    }
    
    @objc func clickToPlaySound(_ sender: UIButton) {
        playSound(type: 1, word: word!.name)
    }
    
    func playSound(type: Int, word: String) {
        let request = "http://dict.youdao.com/dictvoice?type=" + String(type) + "&audio=" + word
        
        Alamofire.request(request).responseData { response in
            guard let data = response.result.value else { return }
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                self.player = try AVAudioPlayer(data: data)
                self.player?.prepareToPlay()
                self.player?.play()
            } catch {
                print("play audio failed")
            }
        }
    }
    
    //http://47.103.3.131:5000/wordDetail
    func getDetail(word: String){
        let parameters = ["word": word]
        let request = "http://47.103.3.131:5000/wordDetail"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let data = response.data {
                let wordDetailHtml = try! JSONDecoder().decode(WordDetailHtml.self, from: data)
                self?.html = wordDetailHtml.html
                self?.css = wordDetailHtml.css
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            }
        }
    }
    
    //http://47.103.3.131:5000/getSimilarWords
    func getSimilarWords(word: String){
        let parameters = ["word": word]
        let request = "http://47.103.3.131:5000/getSimilarWords"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                let simiarWords = try! JSONDecoder().decode([Word].self, from: data)
                self?.similarWords = simiarWords
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            }
        }
    }


}

extension LearningCardView {
    func clearAll(){
        if self.subviews.count>0 {
            self.subviews.forEach({ $0.removeFromSuperview()});
        }
    }
    
    func viewController()->UIViewController? {
        var nextResponder: UIResponder? = self
        repeat {
            nextResponder = nextResponder?.next
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        } while nextResponder != nil
        return nil
    }
}
