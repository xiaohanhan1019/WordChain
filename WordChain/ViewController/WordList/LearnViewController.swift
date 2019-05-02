//
//  LearnViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/30.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import LinearProgressBar

class LearnViewController: UIViewController, UITableViewDelegate {

    var wordList: WordList? = nil
    
    @IBOutlet weak var progressBar: LinearProgressBar!
    @IBOutlet weak var learningCardView: LearningCardView!
    @IBOutlet weak var knowBtn: UIButton!
    @IBOutlet weak var unknownBtn: UIButton!
    
    var currentIdx = 0 {
        didSet {
            UIView.transition(
                with: progressBar,
                duration: 0.5,
                options: [.transitionCrossDissolve],
                animations: {
                    self.progressBar.progressValue = CGFloat(self.rightCnt) / CGFloat(self.wordCnt) * 100.0
            })
        }
    }
    
    var wordCnt = 0
    var rightCnt = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        learningCardView.word = wordList!.words[currentIdx]
        progressBar.progressValue = 0.0
        wordCnt = wordList!.words.count
    }
    
    @IBAction func exit(_ sender: Any) {
        showExitConfirmAlert()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func learnWords(_ sender: UIButton) {
        if sender == knowBtn {
            rightCnt = rightCnt + 1
        } else if sender == unknownBtn {
            // 插到末尾
            wordList!.words.insert(wordList!.words[currentIdx], at: wordList!.words.count)
        }
        
        currentIdx = currentIdx + 1
        if currentIdx == wordList!.words.count {
            showCompleteAlert()
        } else {
            UIView.transition(
                with: learningCardView,
                duration: 0.5,
                options: [.transitionCurlUp],
                animations: {
                    self.learningCardView.word = self.wordList!.words[self.currentIdx]
            })
        }
    }
    
    func showCompleteAlert() {
        let msg = String("一共学习了\(wordCnt)个单词")
        let alertController = UIAlertController(title: "恭喜，学习任务已经完成", message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "确定", style: .default) {
            (action: UIAlertAction!) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showExitConfirmAlert() {
        let msg = "马上就完成了！"
        let alertController = UIAlertController(title: "确定要退出吗", message: msg, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default) {
            (action: UIAlertAction!) -> Void in
            // 上传动态
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = learningCardView.similarWordTableView.indexPathForSelectedRow {
                let word = learningCardView.similarWords[indexPath.row]
                
                let controller = (segue.destination) as! WordDetailViewController
                controller.detailWord = word
                // 设置返回键文字
                let item = UIBarButtonItem(title: word.name, style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = item
            }
        }
    }
    
}
