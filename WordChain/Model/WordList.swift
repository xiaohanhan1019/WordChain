//
//  WordList.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/14.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import Foundation

struct WordList: Codable {
    let id: Int
    var name: String
    var words: [Word]
    var image_url: String
    var description: String
    let ownerImage_url: String
    let ownerName: String
    let user_id: Int
}
