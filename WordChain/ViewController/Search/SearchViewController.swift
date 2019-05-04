//
//  MasterViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/1.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    @IBOutlet var wordTableView: UITableView!
    @IBOutlet weak var recommendWordListTable: UITableView!
    
    var recommendWordList = [WordList]()
    
    var searchResult = [Word]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var everyDaySentence: EveryDaySentence? = nil
    @IBOutlet weak var everyDaySentenceImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var sentenceView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    let semaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Word Chain"
        // 搜索框设置
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self

        // 导航栏设置
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        //去除导航栏下边框,设置颜色
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isOpaque = true
        
        //tableview空白部分无分割线
        self.wordTableView.tableFooterView = UIView()
        self.wordTableView.register(UINib(nibName:"WordCell", bundle:nil),forCellReuseIdentifier:"WordCell")
        
        self.recommendWordListTable.tableFooterView = UIView()
        self.recommendWordListTable.register(UINib(nibName:"WordListCell", bundle:nil),forCellReuseIdentifier:"wordListCell")
        self.recommendWordListTable.delegate = self
        self.recommendWordListTable.dataSource = self
        self.recommendWordListTable.separatorStyle = .none
        self.recommendWordListTable.isScrollEnabled = false
        
        spinner.startAnimating()
        getEveryDaySentence()
        getRecommendWordList()
    }
    
    func updateUI() {
        everyDaySentenceImageView.downloadedFrom(link: everyDaySentence!.img_url, cornerRadius: 16.0, ratio:CGFloat(4.0/3.0))
        everyDaySentenceImageView.contentMode = .scaleAspectFill
        sentenceView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        contentLabel.text = everyDaySentence?.content
        translationLabel.text = everyDaySentence?.translation
        authorLabel.text = String("-- \(everyDaySentence!.author)")
        authorLabel.textAlignment = .right
        
        recommendWordListTable.reloadData()
        spinner.stopAnimating()
    }
    
    // MARK: - Table View DataSoure
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == wordTableView {
            return searchResult.count
        }else {
            return recommendWordList.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == recommendWordListTable {
            return "词单推荐"
        }
        return ""
    }
    
    // 修改header背景色
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == recommendWordListTable {
            return 32.0
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == wordTableView {
            let word = searchResult[indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
            if let wordCell = cell as? WordCell {
                wordCell.word = word
            }
            return cell
        } else {
            let wordList = recommendWordList[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "wordListCell", for: indexPath)
            if let wordListCell = cell as? WordListCell {
                wordListCell.wordList = wordList
            }
            return cell
        }
    }
    
    // 返回时取消选中
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == wordTableView {
            self.performSegue(withIdentifier: "showDetail", sender: tableView)
            wordTableView.deselectRow(at: indexPath, animated: true)
        } else {
            self.performSegue(withIdentifier: "showWordListDetail", sender: tableView)
            recommendWordListTable.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // 点击cancel隐藏tableview
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        wordTableView.isHidden = true
    }
    
    //点击Search按钮进入搜索结果的第一个cell
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // TODO
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = wordTableView.indexPathForSelectedRow {
                let word = searchResult[indexPath.row]
                
                let controller = (segue.destination) as! WordDetailViewController
                controller.detailWord = word
                // 设置返回键文字
                let item = UIBarButtonItem(title: word.name, style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = item
            }
        } else if segue.identifier == "showWordListDetail" {
            if let indexPath = recommendWordListTable.indexPathForSelectedRow {
                let wordList = recommendWordList[indexPath.row]
                
                let controller = (segue.destination) as! WordListDetailTableViewController
                controller.wordList = wordList
                // 设置返回键文字
                let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = item
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if !searchText.isEmpty {
            searchWords(search: searchText)
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    //http://47.103.3.131:5000/searchWord
    func searchWords(search: String) {
        let parameters = ["search": search]
        let request = "http://47.103.3.131:5000/searchWord"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
    
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            let statusCode = response.response?.statusCode
            if statusCode == 200, let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print(utf8Text)
                self?.searchResult = try! JSONDecoder().decode([Word].self, from: data)
                DispatchQueue.main.async {
                    self?.wordTableView.reloadData()
                }
            }
        }
    }
    
    func getEveryDaySentence() {
        let request = "http://47.103.3.131:5000/getEveryDaySentence"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()
            Alamofire.request(request, method: .get).responseJSON(queue: queue) { [weak self] response in
                
                let statusCode = response.response?.statusCode
                if statusCode == 200, let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print(utf8Text)
                    self?.everyDaySentence = try! JSONDecoder().decode(EveryDaySentence.self, from: data)
                }
                self?.semaphore.signal()
            }
        }
    }
    
    // 获取推荐词单
    func getRecommendWordList() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let parameters = ["user_id": userId]
        let request = "http://47.103.3.131:5000/getRecommendWordList"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()
            Alamofire.request(request, method: .post, parameters: parameters).responseJSON { [weak self] response in
                
                if let statusCode = response.response?.statusCode, let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("getRecommendWordList: \(utf8Text)")
                    if statusCode == 200 {
                        self?.recommendWordList = try! JSONDecoder().decode([WordList].self, from: data)
                    }
                }
                
                DispatchQueue.main.async {
                    UIView.transition(
                        with: self!.view,
                        duration: 0.2,
                        options: [.transitionCrossDissolve],
                        animations: {
                            self?.updateUI()
                    })
                }
                
                self?.semaphore.signal()
            }
        }
    }
    
//    //http://47.103.3.131:5000/searchWord
//    func searchWords(search: String)
//    {
//        let session = URLSession(configuration: .default)
//
//        let json = ["search":search]
//        let jsonData = try? JSONSerialization.data(withJSONObject: json)
//
//        let url = URL(string: "http://47.103.3.131:5000/searchWord")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//
//        let task = session.dataTask(with: request) { [weak self] (data: Data?, response, error) in
//            if let error = error {
//                print("error: \(error)")
//            } else {
//                if let response = response as? HTTPURLResponse {
//                    print("statusCode: \(response.statusCode)")
//                }
//                if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                    print("data: \(dataString)")
//                    // TODO try!的问题
//                    // TODO 手机里应该有内置的数据库,用来搜索显示解释以及用户的一些数据(查询了多少次)
//                    self?.searchResult = try! JSONDecoder().decode([Word].self, from: data)
//                    DispatchQueue.main.async {
//                        self?.wordTableView.reloadData()
//                    }
//                }
//            }
//        }
//        task.resume()
//    }
    
    
}

extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        if !searchBarIsEmpty() {
            UIView.transition(
                with: self.view,
                duration: 0.2,
                options: [.transitionCrossDissolve],
                animations: {
                    self.wordTableView.isHidden = false
                    self.everyDaySentenceImageView.isHidden = true
                    self.contentLabel.isHidden = true
                    self.translationLabel.isHidden = true
                    self.authorLabel.isHidden = true
                    self.sentenceView.isHidden = true
                    self.recommendWordListTable.isHidden = true
            })
        } else {
            UIView.transition(
                with: self.view,
                duration: 0.2,
                options: [.transitionCrossDissolve],
                animations: {
                    self.wordTableView.isHidden = true
                    self.everyDaySentenceImageView.isHidden = false
                    self.contentLabel.isHidden = false
                    self.translationLabel.isHidden = false
                    self.authorLabel.isHidden = false
                    self.sentenceView.isHidden = false
                    self.recommendWordListTable.isHidden = false
            })
        }
    }
}
