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
    
    @IBOutlet weak var progressBar: LinearProgressBar! {
        didSet {
            progressBar.progressValue = 0.0
        }
    }
    @IBOutlet weak var learningCardView: LearningCardView!
    @IBOutlet weak var knowBtn: UIButton!
    @IBOutlet weak var unknownBtn: UIButton!
    
    var currentWord = 0 {
        didSet {
            progressBar.progressValue = CGFloat(currentWord / (wordList?.words.count)!)
        }
    }
    
    var knowWordCnt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        learningCardView.word = wordList!.words[currentWord]
    }
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        showExitConfirmAlert()
    }
    
    @IBAction func learnWords(_ sender: UIButton) {
        if sender == knowBtn {
            knowWordCnt = knowWordCnt + 1
        } else if sender == unknownBtn {
            
        }
        currentWord = currentWord + 1
        
        if currentWord == wordList!.words.count {
            showCompleteAlert()
        }
    }
    
    func showCompleteAlert() {
        let msg = String("一共学习了\(wordList?.words.count)个单词,其中认识\(knowWordCnt)个,不认识\((wordList?.words.count)! - knowWordCnt)个")
        let alertController = UIAlertController(title: "恭喜，学习任务已经完成", message: msg, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default) {
            (action: UIAlertAction!) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showExitConfirmAlert() {
        
    }
    
}
