//
//  WordListCell.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/14.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class WordListCell: UITableViewCell {
    
    @IBOutlet weak var wordListCoverImage: UIImageView!
    @IBOutlet weak var wordListName: UILabel!
    @IBOutlet weak var wordListInfo: UILabel!
    
    var wordList: WordList? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        wordListName.text = wordList!.name
        wordListInfo.text = String(wordList!.words.count)
    }
    
}
