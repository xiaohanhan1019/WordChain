//
//  MasterViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/1.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate, UISearchBarDelegate{
    
    // MARK: - Properties
    @IBOutlet var wordTableView: UITableView!
    
    var detailViewController: WordDetailViewController? = nil
    var words = [Word]()
    var filteredWords = [Word]()
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Word Chain"
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        //去除导航栏下边框
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //tableview空白部分无分割线
        self.wordTableView.tableFooterView = UIView()
        
        words = [
            Word(name: "acclaim", meaning: "称赞"),
            Word(name: "reclaim", meaning: "声称")
        ]
        
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? WordDetailViewController
        }
    }
    
    // 解决刚开应用进入detail问题
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    // MARK: - Split view
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? WordDetailViewController else { return false }
        if topAsDetailController.detailWord == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if splitViewController!.isCollapsed {
            if let selectionIndexPath = self.wordTableView.indexPathForSelectedRow {
                self.wordTableView.deselectRow(at: selectionIndexPath, animated: animated)
            }
        }
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredWords.count
        }
        
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let word: Word
        if isFiltering() {
            word = filteredWords[indexPath.row]
        } else {
            word = words[indexPath.row]
        }
        cell.textLabel!.text = word.name
        cell.detailTextLabel!.text = word.meaning
        return cell
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
                let word: Word
                if isFiltering() {
                    word = filteredWords[indexPath.row]
                } else {
                    word = words[indexPath.row]
                }
                
                let controller = (segue.destination as! UINavigationController).topViewController as! WordDetailViewController
                controller.detailWord = word
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                // 设置返回键文字
                let item = UIBarButtonItem(title: word.name, style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = item
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Private instance methods
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredWords = words.filter({( word : Word) -> Bool in
            return word.name.lowercased().contains(searchText.lowercased())
        })
        
        wordTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
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
