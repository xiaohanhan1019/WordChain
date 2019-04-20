//
//  MasterViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/1.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    @IBOutlet var wordTableView: UITableView!
    
    var detailViewController: WordDetailViewController? = nil
    var searchResult = [Word]()
    let searchController = UISearchController(searchResultsController: nil)
    
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
        // 导航栏颜色
        if let navigationbar = self.navigationController?.navigationBar {
            navigationbar.barTintColor = UIColor.white
        }
        // 导航栏设置
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        //去除导航栏下边框
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //tableview空白部分无分割线
        self.wordTableView.tableFooterView = UIView()
    }
    
    // MARK: - Table View DataSoure
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let word = searchResult[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        if let wordCell = cell as? WordCell {
            wordCell.word = word
        }

        return cell
    }
    
    // 返回时取消选中
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        wordTableView.deselectRow(at: indexPath, animated: true)
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
    func searchWords(search: String)
    {
        let session = URLSession(configuration: .default)
        
        let json = ["search":search]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://47.103.3.131:5000/searchWord")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request) { [weak self] (data: Data?, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                    // TODO try!的问题
                    // TODO 手机里应该有内置的数据库,用来搜索显示解释以及用户的一些数据(查询了多少次)
                    self?.searchResult = try! JSONDecoder().decode([Word].self, from: data)
                    DispatchQueue.main.async {
                        self?.wordTableView.reloadData()
                    }
                }
            }
        }
        task.resume()
    }
    
    
}

extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        if !searchBarIsEmpty() {
            wordTableView.isHidden = false
        } else {
            wordTableView.isHidden = true
        }
    }
}
