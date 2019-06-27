//
//  AppCoordinator.swift
//  ChuckNorrisFacts
//
//  Created by Eduardo Brandalise on 07/02/19.
//  Copyright © 2019 Eduardo Brandalise. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    
    var window: UIWindow?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let factView = FactView(category: Category(name: ""), facts: [], initialFactIndex: 0)
        
        self.window?.rootViewController = factView
    }
}
