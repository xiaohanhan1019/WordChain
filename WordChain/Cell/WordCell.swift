//
//  WordCell.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/18.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class WordCell: UITableViewCell {
    
    @IBOutlet weak var wordNameLabel: UILabel!
    @IBOutlet weak var wordDetailLabel: UILabel!
    @IBOutlet weak var wordImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var word: Word? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        wordNameLabel.text = word?.name
        wordDetailLabel.text = word?.meaning
        wordImageView.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }
    
}
