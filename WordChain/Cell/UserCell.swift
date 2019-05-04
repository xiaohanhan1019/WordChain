//
//  UserCell.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/5/3.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var user: User? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI() {
        userName.text = user?.nickname
        userStatus.text = user?.status
        if user?.image_url == "" {
            userImageView.downloadedFrom(link: "http://47.103.3.131/default.jpg", cornerRadius: 32)
        } else {
            userImageView.downloadedFrom(link: user?.image_url ?? "http://47.103.3.131/default.jpg", cornerRadius: 32)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //wordListCoverImage.image = nil
    }
    
}
