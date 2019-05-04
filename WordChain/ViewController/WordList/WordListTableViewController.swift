//
//  WordListTableViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/14.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

class WordListTableViewController: UITableViewController {
    
    var userWordLists = [WordList]()
    var userLikedWordLists = [WordList]()
    
    let semaphore = DispatchSemaphore(value: 1)
    
    //var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "我的"
        
        // 绘制spinner
//        spinner = UIActivityIndicatorView(style: .whiteLarge)
//        spinner.backgroundColor = UIColor.darkGray
//        spinner.layer.cornerRadius = 16
//        spinner.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
//        spinner.center.x = self.view.center.x
//        spinner.center.y = self.view.center.y-100
//        self.view.addSubview(spinner)
//        spinner.startAnimating()
        
        // 去除导航栏下边框,设置颜色
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        // 去除tableview分割线
        self.tableView.separatorStyle = .none
        
        // 右上角添加词单按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.clickToAddWordList))
        
        //创建重用cell
        self.tableView.register(UINib(nibName:"WordListCell", bundle:nil),forCellReuseIdentifier:"wordListCell")
        
        let searchWordListBtn = UIButton(type: .custom)
        searchWordListBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        searchWordListBtn.setImage(UIImage(named:"search"), for: .normal)
        searchWordListBtn.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        let searchWordListBarItem = UIBarButtonItem(customView: searchWordListBtn)
        let currWidth = searchWordListBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = searchWordListBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = searchWordListBarItem
        searchWordListBtn.addTarget(self, action: #selector(self.pushSearchWordListPage), for: UIControl.Event.touchUpInside)
    }
    
    @objc func pushSearchWordListPage() {
        let sb = UIStoryboard(name: "Main", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "searchWordList") as! SearchWordListViewController
        
        //去掉后退键文字
        let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        getUserWordList()
        getUserLikedWordList()
    }
    
    func updateUI() {
        self.tableView.reloadData()
        //spinner.stopAnimating()
    }
    
    @objc func clickToAddWordList() {
        let alertController = UIAlertController(title: "新建词单", message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default) {
            (action: UIAlertAction!) -> Void in
            if let wordListName = alertController.textFields?.first?.text{
                if wordListName.isEmpty {
                    let alertToast = UIAlertController(title: "词单标题不能为空！", message: nil, preferredStyle: .alert)
                    self.present(alertToast, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            alertToast.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    self.addWordList(wordListName: wordListName)
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "词单标题"
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section{
        case 0:
            return userWordLists.count
        case 1:
            return userLikedWordLists.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "我的词单"
        case 1:
            return "我的收藏"
        default:
            return "xxx"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // 第二种方法去掉多余的分割线
        return 0.001
    }
    
    // 修改header背景色
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var wordList: WordList
        
        if indexPath.section == 0{
            wordList = userWordLists[indexPath.row]
        } else {
            wordList = userLikedWordLists[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordListCell", for: indexPath) as! WordListCell
        cell.wordList = wordList
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showWordListDetail", sender: tableView)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWordListDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var wordList: WordList
                if indexPath.section == 0 {
                    wordList = userWordLists[indexPath.row]
                } else {
                    wordList = userLikedWordLists[indexPath.row]
                }
                
                let controller = (segue.destination) as! WordListDetailTableViewController
                controller.wordList = wordList
                
                //去掉后退键文字
                let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = item
            }
        }
    }
    
    //获取用户创建的单词表
    //http://47.103.3.131:5000/getAllUserWordList
    // 应该可以同时获取数据,但python那边有些问题,所以这里用信号量实现串行
    func getUserWordList() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let parameters = ["user_id": userId]
        let request = "http://47.103.3.131:5000/getAllUserWordList"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()
            Alamofire.request(request, method: .post, parameters: parameters).responseJSON { [weak self] response in
                
                if let statusCode = response.response?.statusCode, let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("getUserWordList: \(utf8Text)")
                    if statusCode == 200 {
                        self?.userWordLists = try! JSONDecoder().decode([WordList].self, from: data)
                    }
                }
                
                self?.semaphore.signal()
            }
        }
    }
    
    // 获取用户收藏单词表
    //http://47.103.3.131:5000/getAllUserLikedWordList
    func getUserLikedWordList(){
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let parameters = ["user_id": userId]
        let request = "http://47.103.3.131:5000/getAllUserLikedWordList"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()
            Alamofire.request(request, method: .post, parameters: parameters).responseJSON { [weak self] response in
                
                if let statusCode = response.response?.statusCode, let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("getUserLikedWordList: \(utf8Text)")
                    if statusCode == 200 {
                        self?.userLikedWordLists = try! JSONDecoder().decode([WordList].self, from: data)
                    }
                }
                
                DispatchQueue.main.async {
                    UIView.transition(
                        with: self!.view,
                        duration: 0.5,
                        options: [.transitionCrossDissolve],
                        animations: {
                            self?.updateUI()
                    })
                }
                
                self?.semaphore.signal()
            }
        }
    }
    
    // 添加词单
    func addWordList(wordListName: String) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        let parameters = ["wordList_name": wordListName, "user_id": userId] as [String : Any]
        let request = "http://47.103.3.131:5000/addWordList"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode {
                print("status code: \(statusCode)")
                if statusCode == 200 {
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)")
                        let newWordList = try! JSONDecoder().decode(WordList.self, from: data)
                        
                        DispatchQueue.main.async {
                            let alertToast = UIAlertController(title: "新建成功", message: nil, preferredStyle: .alert)
                            self?.userWordLists.append(newWordList)
                            self?.tableView.insertRows(at: [IndexPath(row: (self?.userWordLists.count)!-1, section: 0)], with: .fade)
                            
                            self?.present(alertToast, animated: true) {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                    alertToast.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let alertToast = UIAlertController(title: "添加失败", message: nil, preferredStyle: .alert)
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
