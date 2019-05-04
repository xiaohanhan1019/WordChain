//
//  searchFriendViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/5/3.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

class SearchFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var searchResultTableView: UITableView!
    
    var searchResult = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "搜索朋友"
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
        
        //tableview空白部分无分割线
        self.searchResultTableView.tableFooterView = UIView()
        self.searchResultTableView.register(UINib(nibName:"UserCell", bundle:nil),forCellReuseIdentifier:"userCell")
        self.searchResultTableView.delegate = self
        self.searchResultTableView.dataSource = self
    }
    
    // MARK: - Table View DataSoure
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = searchResult[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        if let userCell = cell as? UserCell {
            userCell.user = user
        }
        
        return cell
    }
    
    // 返回时取消选中
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showUserInfo", sender: tableView)
        searchResultTableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserInfo" {
            if let indexPath = searchResultTableView.indexPathForSelectedRow {
                let user = searchResult[indexPath.row]
                
                let controller = (segue.destination) as! UserInfoTableViewController
                controller.user = user
                
                //去掉后退键文字
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
            searchUsers(search: searchText)
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    //http://47.103.3.131:5000/
    func searchUsers(search: String) {
        let parameters = ["search": search]
        let request = "http://47.103.3.131:5000/searchUser"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            let statusCode = response.response?.statusCode
            if statusCode == 200, let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print(utf8Text)
                self?.searchResult = try! JSONDecoder().decode([User].self, from: data)
                DispatchQueue.main.async {
                    UIView.transition(
                        with: self!.searchResultTableView,
                        duration: 0.5,
                        options: [.transitionCrossDissolve],
                        animations: {
                            self?.searchResultTableView.reloadData()
                    })
                }
            }
        }
    }
    
}

extension SearchFriendViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        if !searchBarIsEmpty() {
            searchResultTableView.isHidden = false
        } else {
            searchResultTableView.isHidden = true
        }
    }
}
