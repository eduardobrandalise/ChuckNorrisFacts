//
//  FactError.swift
//  ChuckNorrisFacts
//
//  Created by Eduardo Brandalise on 23/02/19.
//  Copyright © 2019 Eduardo Brandalise. All rights reserved.
//

import Result

class FactError: LocalizedError {
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    var errorDescription: String? {
        return self.message
    }
}
