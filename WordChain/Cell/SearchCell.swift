//
//  SearchCell.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/14.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    
    @IBOutlet weak var searchCellWordName: UILabel!
    @IBOutlet weak var searchCellWordInfo: UILabel!
    
    var word: Word? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        searchCellWordName?.text = word?.name
    }
}
