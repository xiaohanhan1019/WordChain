//
//  WordListTableViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/14.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class WordListTableViewController: UITableViewController {
    
    var userWordLists = [WordList]()
    var userLikedWordLists = [WordList]()
    // todo 信号量保证两个数据获取顺序，其实可以同时获取吧？
    let semaphore = DispatchSemaphore(value: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //去除导航栏下边框,设置颜色
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        getUserWordList()
        getUserLikedWordList()
    }
    
    func updateUI() {
        self.tableView.reloadData()
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
    
    // 修改footerView颜色
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView()
//        footerView.backgroundColor = UIColor.red
//        return footerView
//    }
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordListCell", for: indexPath)
        if let wordListCell = cell as? WordListCell {
            wordListCell.wordList = wordList
            wordListCell.wordListInfo.text = String("count: \(wordList.words.count)")
        }
        
        return cell
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
            }
        }
    }
    
    //获取用户创建的单词表
    //http://47.103.3.131:5000/getAllUserWordList
    func getUserWordList()
    {
        let session = URLSession(configuration: .default)
        
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        let json = ["user_id":userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://47.103.3.131:5000/getAllUserWordList")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        semaphore.wait()
        let task = session.dataTask(with: request) { [weak self] (data: Data?, response, error) in
            if let error = error {
                print("error: \(error)")
                // TODO 获取不到UI反馈
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                    self?.userWordLists = try! JSONDecoder().decode([WordList].self, from: data)
                }
            }
            self?.semaphore.signal()
        }
        task.resume()
    }
    
    // 获取用户收藏单词表
    //http://47.103.3.131:5000/getAllUserLikedWordList
    func getUserLikedWordList(){
        let session = URLSession(configuration: .default)
        
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        let json = ["user_id":userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://47.103.3.131:5000/getAllUserLikedWordList")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        semaphore.wait()
        let task = session.dataTask(with: request) { [weak self] (data: Data?, response, error) in
            if let error = error {
                print("error: \(error)")
                // TODO 获取不到UI反馈
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                    self?.userLikedWordLists = try! JSONDecoder().decode([WordList].self, from: data)
                    
                    DispatchQueue.main.async {
                        self?.updateUI()
                    }
                }
            }
            self?.semaphore.signal()
        }
        task.resume()
    }

}
