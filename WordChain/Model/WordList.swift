//
//  WordList.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/14.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import Foundation

struct WordList: Codable {
    let name: String
    let words: [Word]
}
