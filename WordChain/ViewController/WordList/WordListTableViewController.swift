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
    
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "我的"
        
        // 绘制spinner
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.backgroundColor = UIColor.darkGray
        spinner.layer.cornerRadius = 16
        spinner.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        spinner.center.x = self.view.center.x
        spinner.center.y = self.view.center.y-100
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        // 去除导航栏下边框,设置颜色
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        //去除tableview分割线
        self.tableView.separatorStyle = .none
        
        //创建重用cell
        self.tableView.register(UINib(nibName:"WordListCell", bundle:nil),forCellReuseIdentifier:"wordListCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserWordList()
        getUserLikedWordList()
    }
    
    func updateUI() {
        self.tableView.reloadData()
        spinner.stopAnimating()
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
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    self?.userWordLists = try! JSONDecoder().decode([WordList].self, from: data)
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
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    self?.userLikedWordLists = try! JSONDecoder().decode([WordList].self, from: data)
                }
                
                DispatchQueue.main.async {
                    self?.updateUI()
                }
                
                self?.semaphore.signal()
            }
        }
    }
    
}
