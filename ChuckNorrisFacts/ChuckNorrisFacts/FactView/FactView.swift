//
//  FactView.swift
//  ChuckNorrisFacts
//
//  Created by Eduardo Brandalise on 07/02/19.
//  Copyright © 2019 Eduardo Brandalise. All rights reserved.
//

import UIKit

class FactView: UIViewController {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var factTextView: UITextView!
    @IBOutlet weak var factCategoryLabel: UILabel!
    @IBOutlet weak var factIdLabel: UILabel!
    @IBOutlet weak var factUrlLabel: UILabel!
    @IBOutlet weak var previousFactButton: UIButton!
    @IBOutlet weak var nextFactButton: UIButton!
    
    var viewModel: FactViewModel
    var category: Category
    var loadTimer: Timer
    
    let loadingView: UIAlertController = {
        let alert = UIAlertController(title: nil, message: "Loading Fact...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        
        return alert
    }()
    
    init(category: Category?, facts: [Fact]?, initialFactIndex: Int?) {
        self.category = category ?? Category(name: "")
        let facts = facts ?? []
        self.loadTimer = Timer(timeInterval: 0, invocation: .init(), repeats: false)
        self.viewModel = FactViewModel(category: category, facts: facts)
        
        super.init(nibName: String(describing: FactView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.previousFactButton.isHidden = true
        self.nextFactButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.retrieveFact() 
        self.retrieveImage()
    }
    
    func presentLoadingView() {
        present(self.loadingView, animated: true, completion: nil)
    }
    
    func dismissLoadingView() {
        dismiss(animated: true, completion: nil)
    }
    
    func startTimer() {
        self.loadTimer.invalidate()
        self.loadTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] _ in
            self?.cancelRequest()
        })
    }
    
    func stopTimer() {
        self.loadTimer.invalidate()
    }
    
    func retrieveFact() {
        self.presentLoadingView()
        self.viewModel.getNewFact { [weak self] (fact, error) in
            guard let self = self else { return }
//            DispatchQueue.main.async { self.startTimer() }
            self.startTimer()
            if let e = error {
                print(e)
            } else {
                self.stopTimer()
                self.dismissLoadingView()
                self.updateFact(fact: fact)
            }
        }
    }
    
    func retrievePreviousFacts() -> (Fact, NeighboringPositions) {
        return self.viewModel.getPreviousFact()
    }
    
    func retrieveNextFact() -> (Fact, NeighboringPositions) {
        return self.viewModel.getNextFact()
    }
    
    func retrieveImage() {
        self.viewModel.getImage { (image, error) in
            self.iconImage.image = image
        }
    }
    
    func updateFact(fact: (Fact, NeighboringPositions)) {
        self.updateHistoryButtons(factPosition: fact.1)
        self.factTextView.text = fact.0.value
        self.factCategoryLabel.text = self.category.name.isEmpty ? "" : "Category: \(self.category.name)"
        self.factIdLabel.text = fact.0.id
        self.factUrlLabel.text = fact.0.url
    }
    
    private func updateHistoryButtons(factPosition: NeighboringPositions) {
        if factPosition.hasPrevious {
            self.previousFactButton.isHidden = false
        } else {
            self.previousFactButton.isHidden = true
        }
        
        if factPosition.hasNext {
            self.nextFactButton.isHidden = false
        } else {
            self.nextFactButton.isHidden = true
        }
    }
    
    @objc func cancelRequest() {
        self.loadTimer.invalidate()
        self.viewModel.cancelRequest()
        self.dismissLoadingView()
        //TODO: Show error alert
    }
    
    //MARK: - IBActions
    
    @IBAction func showPreviousFact(_ sender: UIButton) {
        self.updateFact(fact: self.retrievePreviousFacts())
    }
    
    @IBAction func showNextFact(_ sender: UIButton) {
        self.updateFact(fact: self.retrieveNextFact())
    }
    
    @IBAction func getNewFact(_ sender: UIButton) {
        self.retrieveFact()
    }
}
