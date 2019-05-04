//
//  Moment.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/5/3.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import Foundation

struct Moment: Codable {
    let wordList: WordList
    let user: User
    let create_time: String
}
