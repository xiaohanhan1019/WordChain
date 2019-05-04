//
//  MomentTableViewCell.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/5/3.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class MomentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var momentTimeLabel: UILabel!
    
    @IBOutlet weak var wordListCoverImageView: UIImageView!
    @IBOutlet weak var wordListNameLabel: UILabel!
    @IBOutlet weak var wordListDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var moment: Moment? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        if moment?.user.image_url == "" {
            userImageView.downloadedFrom(link: "http://47.103.3.131/default.jpg", cornerRadius: 18)
        } else {
            userImageView.downloadedFrom(link: moment?.user.image_url ?? "http://47.103.3.131/default.jpg", cornerRadius: 18)
        }
        userNameLabel.text = (moment?.user.nickname)! + " 学习了词单:"
        momentTimeLabel.text = moment?.create_time
        
        if moment?.wordList.image_url == "" {
            wordListCoverImageView.downloadedFrom(link: "http://47.103.3.131/default.jpg", cornerRadius: 10)
        } else {
            wordListCoverImageView.downloadedFrom(link: moment?.wordList.image_url ?? "http://47.103.3.131/default.jpg", cornerRadius: 10)
        }
        wordListNameLabel.text = moment?.wordList.name
        wordListDetailLabel.text = String("共\(moment?.wordList.words.count ?? 0)个单词")
    }
    
}
