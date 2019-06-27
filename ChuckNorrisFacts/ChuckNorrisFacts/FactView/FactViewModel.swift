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
    
    //MARK: - Variables
    let provider: MoyaProvider<ApiRouter>
    let category: Category
    var facts: [Fact]
    var currentFactIndex = 0
    private var requestFact: Cancellable?
    private var requestImage: Cancellable?
    
    typealias ImageRetrieved = (UIImage, Error?) -> Void
    typealias FactRetrieved = ((Fact, NeighboringPositions), Error?) -> Void
    
    //MARK: - Init
    init(category: Category?, facts: [Fact]?) {
        self.category = category ?? Category(name: "")
        self.facts = facts ?? []
        self.provider = MoyaProvider()
    }
    
    //MARK: - Requests
    func getNewFact(callback: @escaping FactRetrieved) {
        if category.name.isEmpty {
            self.requestFact = self.provider.request(.random) { result in
                let mappedResult = self.mapResult(result: result)
                self.updateFacts(newFact: mappedResult.0)
                callback((mappedResult.0, self.setNeighboringPositions()), mappedResult.1)
            }
        } else {
            self.requestFact? = self.provider.request(.randomByCategory(category: self.category)) { result in
                let mappedResult = self.mapResult(result: result)
                self.updateFacts(newFact: mappedResult.0)
                callback((mappedResult.0, self.setNeighboringPositions()), mappedResult.1)
            }
        }
        self.currentFactIndex = 0
    }
    
    private func mapResult(result: Result<Response, MoyaError>) -> (Fact, Error?) {
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
    
    //MARK: - History
    func getPreviousFact() -> (Fact, NeighboringPositions) {
        let fact = self.facts[self.currentFactIndex + 1]
        self.currentFactIndex = self.currentFactIndex + 1
        let position = self.setNeighboringPositions()
        
        return (fact, position)
    }
    
    func getNextFact() -> (Fact, NeighboringPositions) {
        let fact = self.facts[self.currentFactIndex - 1]
        self.currentFactIndex = self.currentFactIndex - 1
        let position = self.setNeighboringPositions()
        
        return (fact, position)
    }
    
    private func updateFacts(newFact: Fact) {
        if !self.facts.isEmpty && self.facts.count > 9 {
            self.facts.removeLast()
        }
        self.facts.insert(newFact, at: 0)
    }
    
    func setNeighboringPositions() -> NeighboringPositions {
        var previous = false
        var next = false
        
        if self.facts.distance(from: self.currentFactIndex, to: self.facts.endIndex - 1) > 0 {
            previous = true
        } else {
            previous = false
        }
        
        if self.facts.distance(from: self.facts.startIndex, to: self.currentFactIndex) > 0 {
            next = true
        } else {
            next = false
        }
        
        return NeighboringPositions(hasPrevious: previous, hasNext: next)
    }
}
