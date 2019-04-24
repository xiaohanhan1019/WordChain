//
//  User.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/14.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import Foundation

struct User: Codable{
    var nickname : String
    let id : Int
    var status: String
    var image_url: String
}
