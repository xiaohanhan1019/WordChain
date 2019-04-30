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
        
        wordListNameLabel.text = wordList?.name
        wordListInfoLabel.text = wordList?.description
        
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
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var learnBtn: UIButton!
    
    var userOwnThisWordList: Bool {
        return wordList!.user_id == UserDefaults.standard.integer(forKey: "userId")
    }
    
    var userLikeThisWordList: Bool? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "词单"
        //设置右上角编辑键
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
        
        //调接口判断用户是否收藏了该词单
        let userId = UserDefaults.standard.integer(forKey: "userId")
        if userId == wordList?.user_id {
            updateUI()
        } else {
            judgeIfUserLiked(userId: userId, wordListId: wordList!.id)
        }
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
        
        if userOwnThisWordList {
            likeBtn.setImage(UIImage(named: "like"), for: .normal)
        } else if userLikeThisWordList ?? false {
            likeBtn.setImage(UIImage(named: "like"), for: .normal)
        } else {
            likeBtn.setImage(UIImage(named: "heart_empty"), for: .normal)
        }
    }
    
    @IBAction func clickToCollect(_ sender: Any) {
        if !userOwnThisWordList {
            if userLikeThisWordList! {
                //取消收藏
            } else {
                //收藏
            }
        }
    }
    
    @IBAction func clickToLearn(_ sender: Any) {
        
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
        } else if segue.identifier == "learnWord" {
            let controller = (segue.destination) as! LearnViewController
            controller.wordList = wordList
        }
    }

    @objc func editClick() {
        let alert = UIAlertController()
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel,handler:nil)
        let editWordListAction = UIAlertAction(title: "编辑词单信息", style: .default){ (action:UIAlertAction) in
            self.editWordList()
        }
        let sortWordAction = UIAlertAction(title: "更改单词排序", style: .default){ (action:UIAlertAction) in
            self.sortWord()
        }
        let deleteWordListAction = UIAlertAction(title: "删除词单", style: .destructive){ (action:UIAlertAction) in
            self.deleteWordList()
        }
        
        alert.addAction(sortWordAction)
        if wordList?.user_id == UserDefaults.standard.integer(forKey: "userId") {
            alert.addAction(editWordListAction)
            alert.addAction(deleteWordListAction)
        }
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteWordList() {
        let parameters = ["wordList_id": wordList!.id]
        let request = "http://47.103.3.131:5000/delWordList"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode {
                print("status code: \(statusCode)")
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        let alertToast = UIAlertController(title: "删除成功", message: nil, preferredStyle: .alert)
                        self?.present(alertToast, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                alertToast.dismiss(animated: true) {
                                    // 返回上一级
                                    self?.navigationController?.popViewController(animated:true)
                                }
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
            self.wordList?.words.sort(by: {(word1: Word, word2: Word) -> Bool in return word1.name < word2.name })
            self.tableView.reloadData()
        }
        let sortByRandom = UIAlertAction(title: "随机乱序", style: UIAlertAction.Style.default){ (action:UIAlertAction) in
            self.wordList?.words.shuffle()
            self.tableView.reloadData()
        }
        let sortBySimilarity = UIAlertAction(title: "按相似度排序", style: UIAlertAction.Style.default){ (action:UIAlertAction) in
            self.sortWordBySimilarity()
        }
        alert.addAction(sortByWordName)
        alert.addAction(sortByRandom)
        alert.addAction(sortBySimilarity)
        alert.addAction(cleanAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //http://47.103.3.131:5000/judgeUserLiked
    func judgeIfUserLiked(userId: Int, wordListId: Int){
        let parameters = ["user_id": userId, "wordList_id": wordListId] as [String : Any]
        let request = "http://47.103.3.131:5000/judgeUserLiked"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode {
                print("judge status code: \(statusCode)")
                if statusCode == 200 {
                    self?.userLikeThisWordList = true
                } else {
                    self?.userLikeThisWordList = false
                }
            }
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
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
    
    //Alamofire搞不定
    //http://47.103.3.131:5000/sortWordBySimilarity
    func sortWordBySimilarity(){
        if let jsonData = try? JSONEncoder().encode(wordList){
            if let jsonString = String.init(data: jsonData, encoding: String.Encoding.utf8) {
                print(jsonString)
                
                let url:NSURL = NSURL(string:"http://47.103.3.131:5000/sortWordBySimilarity")!
                
                let request:NSMutableURLRequest = NSMutableURLRequest(url: url as URL) //默认为get请求
                request.timeoutInterval = 5.0 //设置请求超时为5秒
                request.httpMethod = "POST"  //设置请求方法
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

                request.httpBody = jsonData
                let session = URLSession.shared
                
                let task = session.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
                    
                    if let response = response as? HTTPURLResponse {
                        print("statusCode: \(response.statusCode)")
                    }
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        print("data: \(dataString)")
                        self?.wordList?.words = try! JSONDecoder().decode([Word].self, from: data)
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                    
                })
                
                task.resume()
            }
        }
    }
}

extension MutableCollection {
    /// 打乱集合里的元素
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// 返回序列乱序的数组
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
