//
//  WordListDetailTableViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/17.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

class WordListDetailTableViewController: UITableViewController, paramWordListDelegate {
    
    func returnWordListInfo(name: String, description: String,cover: UIImage) {
        wordList?.name = name
        wordList?.description = description
        
        wordListCoverImageView.layer.cornerRadius = 15
        wordListCoverImageView.clipsToBounds = true
        wordListCoverImageView.image = cover.crop(ratio: 1.0)
    }
    
    var wordList: WordList? = nil
    @IBOutlet weak var wordListCoverImageView: UIImageView!
    @IBOutlet weak var wordListNameLabel: UILabel!
    @IBOutlet weak var wordListOwnerImageView: UIImageView!
    @IBOutlet weak var wordListOwnerNameLabel: UILabel!
    @IBOutlet weak var wordListInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "词单"
        //设置左上角返回键,设置大小
        let editBtn = UIButton(type: .custom)
        editBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        editBtn.setImage(UIImage(named:"editWordList"), for: .normal)
        editBtn.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        let addBarItem = UIBarButtonItem(customView: editBtn)
        let currWidth = addBarItem.customView?.widthAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        let currHeight = addBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = addBarItem
        editBtn.addTarget(self, action: #selector(self.editClick), for: UIControl.Event.touchUpInside)
        
        //导航栏颜色，去掉分割线
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
    }
    
    func updateUI() {
        if wordList?.image_url == ""{
            wordListCoverImageView.downloadedFrom(link: "http://47.103.3.131/default.jpg", cornerRadius: 15)
        } else {
            wordListCoverImageView.downloadedFrom(link: wordList?.image_url ?? "http://47.103.3.131/default.jpg", cornerRadius: 15)
        }
        if wordList?.ownerImage_url == ""{
            wordListOwnerImageView.downloadedFrom(link: "http://47.103.3.131/default.jpg", cornerRadius: 14)
        } else {
            wordListOwnerImageView.downloadedFrom(link: wordList?.ownerImage_url ?? "http://47.103.3.131/default.jpg", cornerRadius: 14)
        }
        wordListNameLabel.text = wordList?.name
        wordListInfoLabel.text = wordList?.description
        wordListOwnerNameLabel.text = wordList?.ownerName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordList?.words.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let word = wordList?.words[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        if let wordCell = cell as? WordCell {
            wordCell.word = word
        }
        return cell
    }
    
    // 返回时取消选中
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // 只有用户自己的可以删除
        if wordList?.user_id == UserDefaults.standard.integer(forKey: "userId") {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 删除接口
            if let wordListId = wordList?.id, let wordId = wordList?.words[indexPath.row].id {
                delWordFromWordList(wordListId: wordListId, wordId: wordId)
                
                // 删除 bug: 应该接口删除成功后再删除内存数据
                wordList?.words.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let word = wordList?.words[indexPath.row]
                
                let controller = (segue.destination) as! WordDetailViewController
                controller.detailWord = word
                
                // 设置返回键文字
                let item = UIBarButtonItem(title: word?.name, style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = item
            }
        }
    }

    @objc func editClick() {
        let alert = UIAlertController()
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel,handler:nil)
        let editWordListAction = UIAlertAction(title: "编辑词单信息", style: UIAlertAction.Style.default){ (action:UIAlertAction) in
            self.editWordList()
        }
        let sortWordAction = UIAlertAction(title: "更改单词排序", style: UIAlertAction.Style.default){ (action:UIAlertAction) in
            self.sortWord()
        }
        
        if wordList?.user_id == UserDefaults.standard.integer(forKey: "userId") {
            alert.addAction(editWordListAction)
        }
        alert.addAction(sortWordAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func editWordList() {
        let sb = UIStoryboard(name: "Main", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "editWordList") as! EditWordListTableViewController
        vc.wordList = wordList
        vc.wordListImage = wordListCoverImageView.image
        vc.delegate = self
        
        let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func sortWord() {
        self.dismiss(animated: true, completion: nil)
        let alert = UIAlertController()
        let cleanAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel,handler:nil)
        let sortByWordName = UIAlertAction(title: "按字典序", style: UIAlertAction.Style.default){ (action:UIAlertAction) in
            self.wordList?.words.sort { (word1, word2) -> Bool in
                return word1.name<word2.name
            }
            self.tableView.reloadData()
        }
        let sortByFamiliar = UIAlertAction(title: "按掌握程度排序", style: UIAlertAction.Style.default){ (action:UIAlertAction) in
            
        }
        alert.addAction(sortByWordName)
        alert.addAction(sortByFamiliar)
        alert.addAction(cleanAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //http://47.103.3.131:5000/delWordFromWordList
    func delWordFromWordList(wordListId: Int, wordId: Int){
        let parameters = ["wordList_id": wordListId, "word_id": wordId] as [String : Any]
        let request = "http://47.103.3.131:5000/delWordFromWordList"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode {
                print("status code: \(statusCode)")
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        let alertToast = UIAlertController(title: "删除成功", message: nil, preferredStyle: .alert)
                        self?.present(alertToast, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                alertToast.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let alertToast = UIAlertController(title: "删除失败", message: nil, preferredStyle: .alert)
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
