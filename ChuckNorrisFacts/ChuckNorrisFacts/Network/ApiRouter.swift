//
//  ApiRouter.swift
//  ChuckNorrisFacts
//
//  Created by Eduardo Brandalise on 11/02/19.
//  Copyright © 2019 Eduardo Brandalise. All rights reserved.
//

import Moya

enum ApiRouter {
    case categories
    case random
    case randomByCategory(category: Category)
    case search(searchText: String)
    case image
}

extension ApiRouter: TargetType {
    var baseURL: URL {
        switch self {
        case .categories, .random, .randomByCategory(category: _), .search(searchText: _):
            return URL(string: "https://api.chucknorris.io/jokes/")!
        case .image:
            return URL(string: "https://assets.chucknorris.host/img/avatar/chuck-norris.png")!
        }
    }
    
    var path: String {
        switch self {
        case .categories:
            return "categories"
        case .random:
            return "random"
        case .randomByCategory:
            return "random"
        case .search:
            return "search"
        case .image:
            return ""
        }
    }
    
    var method: Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .categories, .random, .image:
            return .requestPlain
        case let .randomByCategory(category):
            return .requestParameters(parameters: ["category" : category.name], encoding: URLEncoding.default)
        case let .search(text):
            return .requestParameters(parameters: ["query" : text], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
