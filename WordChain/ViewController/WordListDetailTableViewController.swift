//
//  WordListDetailTableViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/17.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class WordListDetailTableViewController: UITableViewController {
    
    var wordList = WordList(name: "", words: [Word]())
    @IBOutlet weak var wordListCoverImageView: UIImageView!
    @IBOutlet weak var wordListNameLabel: UILabel!
    @IBOutlet weak var wordListOwnerImageView: UIImageView!
    @IBOutlet weak var wordListOwnerNameLabel: UILabel!
    @IBOutlet weak var wordListInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordListCoverImageView.downloadedFrom(link: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555944871&di=45dccd9aa19e79602a26e866d9f0c283&imgtype=jpg&er=1&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201610%2F21%2F20161021114501_kKusd.jpeg", cornerRadius: 15)
        wordListNameLabel.text = wordList.name
        wordListOwnerImageView.downloadedFrom(link: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555944871&di=45dccd9aa19e79602a26e866d9f0c283&imgtype=jpg&er=1&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201610%2F21%2F20161021114501_kKusd.jpeg", cornerRadius: 14)
        wordListInfoLabel.text = "testetstetasddfhakdhfkjasdfkntestetstetasddfhakdhfkjasdfkntestetstetasddfhakdhfkjasdfkntestetstetasddfhakdhfkjasdfkn"
        wordListOwnerNameLabel.text = "xiaohanhan"
        
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordList.words.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let word = wordList.words[indexPath.row]
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
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let word = wordList.words[indexPath.row]
                
                let controller = (segue.destination) as! WordDetailViewController
                controller.detailWord = word
                
                // 设置返回键文字
                let item = UIBarButtonItem(title: word.name, style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = item
            }
        }
    }

}
