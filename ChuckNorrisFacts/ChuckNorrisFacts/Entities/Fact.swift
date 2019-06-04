//
//  Fact.swift
//  ChuckNorrisFacts
//
//  Created by Eduardo Brandalise on 11/02/19.
//  Copyright © 2019 Eduardo Brandalise. All rights reserved.
//

import Foundation

struct Fact: Decodable {
    var icon_url: String
    var url: String
    var id: String
    var value: String
}
