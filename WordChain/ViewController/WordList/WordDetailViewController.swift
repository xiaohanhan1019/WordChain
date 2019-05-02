//
//  WordDetailViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/1.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import AVFoundation

class WordDetailViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var detailWord: Word?
    var html: String?
    var css: String?
    
    var player: AVAudioPlayer? = nil
    
    var britishEngBtn: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 24))
//    var americanEngBtn: UIButton = UIButton(frame: CGRect(x: 72, y: 0, width: 72, height: 24))
    
    var wordLists = [WordList]()
    
    func configureView() {
        let wordDetailWebView = WKWebView()
        self.view.addSubview(wordDetailWebView)
        wordDetailWebView.frame = self.view.bounds
        
        // 英式发音按钮 btn宽度小于60不显示文字(坑
        britishEngBtn.setImage(UIImage.init(imageLiteralResourceName: "horn"), for: .normal)
        britishEngBtn.imageView?.contentMode = .scaleAspectFit
        britishEngBtn.setTitle(String(" /\(detailWord!.pronounce)/"), for: .normal)
        britishEngBtn.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        britishEngBtn.addTarget(self, action: #selector(self.clickToPlaySound(_:)), for: UIControl.Event.touchUpInside)
        britishEngBtn.contentHorizontalAlignment = .left
        wordDetailWebView.scrollView.addSubview(britishEngBtn)
        
        // 美式发音按钮
//        americanEngBtn.setImage(UIImage.init(imageLiteralResourceName: "horn"), for: .normal)
//        americanEngBtn.imageView?.contentMode = .scaleAspectFit
//        americanEngBtn.setTitle("美", for: .normal)
//        americanEngBtn.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
//        americanEngBtn.addTarget(self, action: #selector(self.clickToPlaySound(_:)), for: UIControl.Event.touchUpInside)
//        wordDetailWebView.scrollView.addSubview(americanEngBtn)
        
        // 右上角收藏按钮
        let collectBtn = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 20, height: 20))
        // todo 根据用户是否收藏改变icon
        collectBtn.setImage(UIImage(named:"collect_empty"), for: .normal)
        collectBtn.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        let collectBarItem = UIBarButtonItem(customView: collectBtn)
        let currWidth = collectBarItem.customView?.widthAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        let currHeight = collectBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = collectBarItem
        collectBtn.addTarget(self, action: #selector(self.clickToCollect), for: UIControl.Event.touchUpInside)
        
        if let html = html , let css = css {
            self.spinner.stopAnimating()
            wordDetailWebView.loadHTMLString("<p style='padding-top:16px;'></p>"+css+html, baseURL: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spinner.startAnimating()
        getDetail(word: detailWord!.name)
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
    
    @objc func clickToPlaySound(_ sender: UIButton) {
//        if sender == britishEngBtn {
//            playSound(type: 1, word: detailWord!.name)
//        } else if sender == americanEngBtn {
//            playSound(type: 2, word: detailWord!.name)
//        }
        playSound(type: 1, word: detailWord!.name)
    }
    
    func popWordListTable() {
        let alertController = UIAlertController(title: "收藏到词单", message: nil, preferredStyle: .actionSheet)
        
        // controller嵌入alertview
        let controller = UIViewController()
        
        // controller frame设置
        let height: CGFloat = min(340,CGFloat(wordLists.count * 68))
        let rect = CGRect(x: 0, y: 0, width: alertController.view.bounds.size.width - 16, height: height)
        controller.preferredContentSize = rect.size
        
        // tableview设置
        let wordListTableView = UITableView(frame: rect)
        wordListTableView.delegate = self
        wordListTableView.dataSource = self
        wordListTableView.register(UINib(nibName:"WordListCell", bundle:nil),forCellReuseIdentifier:"wordListCell")
        wordListTableView.tableFooterView  = UIView()
        wordListTableView.tableHeaderView  = UIView()
        wordListTableView.separatorStyle = .none
        
        controller.view.addSubview(wordListTableView)
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel,handler:nil)
        
        alertController.view.alpha = 1.0
        alertController.addAction(cancelAction)
        alertController.setValue(controller, forKey: "contentViewController")
    alertController.view.subviews.first?.subviews.first?.subviews.last!.backgroundColor = UIColor.white
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func clickToCollect() {
        getUserWordList()
    }
    
    // tableView delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let wordList = wordLists[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordListCell", for: indexPath)
        if let wordListCell = cell as? WordListCell {
            wordListCell.wordList = wordList
        }
        
        return cell
    }
    
    // 点击收藏
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addToWordList(wordId: detailWord!.id, wordListId: wordLists[indexPath.row].id)
        self.dismiss(animated: true, completion: nil)
    }
    
    //获取用户创建的单词表
    //http://47.103.3.131:5000/getAllUserWordList
    func getUserWordList() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let parameters = ["user_id": userId]
        let request = "http://47.103.3.131:5000/getAllUserWordList"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
                
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                self?.wordLists = try! JSONDecoder().decode([WordList].self, from: data)
                DispatchQueue.main.async {
                    self?.popWordListTable()
                }
            }
        }
    }
    
    //http://47.103.3.131:5000/wordDetail
    func getDetail(word: String){
        let parameters = ["word": word]
        let request = "http://47.103.3.131:5000/wordDetail"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                let wordDetailHtml = try! JSONDecoder().decode(WordDetailHtml.self, from: data)
                self?.html = wordDetailHtml.html
                self?.css = wordDetailHtml.css
                DispatchQueue.main.async {
                    self?.configureView()
                }
            }
        }
    }
    
    //http://47.103.3.131:5000/addWordToWordList
    func addToWordList(wordId: Int, wordListId: Int){
        let parameters = ["wordList_id": wordListId, "word_id": wordId]
        let request = "http://47.103.3.131:5000/addWordToWordList"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode {
                print("status code: \(statusCode)")
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        let alertToast = UIAlertController(title: "已收藏", message: nil, preferredStyle: .alert)
                        // 收藏图标变化
                        self?.present(alertToast, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                alertToast.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let alertToast = UIAlertController(title: "单词已存在", message: nil, preferredStyle: .alert)
                        self?.present(alertToast, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                alertToast.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
}
