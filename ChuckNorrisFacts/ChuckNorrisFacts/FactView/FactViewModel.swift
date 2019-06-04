//
//  FactViewModel.swift
//  ChuckNorrisFacts
//
//  Created by Eduardo Brandalise on 11/02/19.
//  Copyright © 2019 Eduardo Brandalise. All rights reserved.
//

import Moya
import Result

class FactViewModel {
    
    let provider: MoyaProvider<ApiRouter>
    let category: Category
    private var requestFact: Cancellable?
    private var requestImage: Cancellable?
    
    typealias ImageRetrieved = (UIImage, Error?) -> Void
    typealias FactRetrieved = (Fact, Error?) -> Void
    
    init(category: Category?) {
        self.category = category ?? Category(name: "")
        self.provider = MoyaProvider()
    }
    
    func getFact(callback: @escaping FactRetrieved) {
        if category.name.isEmpty {
            self.requestFact = self.provider.request(.random) { result in
                let mappedResult = self.mapResult(result: result)
                callback(mappedResult.0, mappedResult.1)
            }
        } else {
            self.requestFact? = self.provider.request(.randomByCategory(category: self.category)) { result in
                let mappedResult = self.mapResult(result: result)
                callback(mappedResult.0, mappedResult.1)
            }
        }
    }
    
    func mapResult(result: Result<Response, MoyaError>) -> (Fact, Error?) {
        switch result {
        case .success(let response):
            if response.statusCode == 200 {
                do {
                    let fact = try response.map(Fact.self)
                    return (fact, nil)
                } catch let error {
                    return (Fact(icon_url:"", url: "", id: "", value: ""), error)
                }
            } else {
                return (Fact(icon_url: "", url: "", id: "", value: ""), FactError(message: "Fact couldn't be retrieved"))
            }
        case .failure(let error):
            return (Fact(icon_url: "", url: "", id: "", value: ""), error)
        }
    }
    
    func getImage(callback: @escaping ImageRetrieved) {
        self.requestImage = self.provider.request(.image) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 200 {
                    do {
                        let image = try response.mapImage()
                        callback(image, nil)
                    } catch let error {
                        callback(UIImage(), error)
                    }
                } else {
                    print("Image couldn't be retrieved")
                }
            case .failure(let error):
                callback(UIImage(), error)
            }
        }
    }
    
    func cancelRequest() {
        self.requestFact?.cancel()
        self.requestImage?.cancel()
    }
}
