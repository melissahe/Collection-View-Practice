//
//  ViewController.swift
//  Collection-View-Practice
//
//  Created by C4Q on 12/14/17.
//  Copyright © 2017 Melissa He @ C4Q. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController {
    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    @IBOutlet weak var cardsSearchBar: UISearchBar!
    
    let defaults = UserDefaults.standard
    let searchKey = "searchKey"
    
    var cards: [Card] = []
    var searchTerm: String = "" {
        didSet {
            loadCards(from: searchTerm)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedSearchTerm = defaults.value(forKey: searchKey) as? String {
            searchTerm = savedSearchTerm
            cardsSearchBar.text = savedSearchTerm
        }
        cardsCollectionView.dataSource = self
        cardsCollectionView.delegate = self
        cardsSearchBar.delegate = self
    }
    
    func loadCards(from searchTerm: String) {
        guard let formattedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            print("bad query")
            return
        }
        
        let urlString = "https://api.magicthegathering.io/v1/cards?name=\(formattedSearchTerm)"
        
        CardAPIClient.manager.getCards(
            from: urlString,
            completionHandler: { (onlineCards) in
                self.cards = onlineCards
                self.cardsCollectionView.reloadData()
        },
            errorHandler: {print($0)})
    }

    func presentAlertController(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

//delegate
extension CardsViewController: UICollectionViewDelegate {
    
    //what happens when you click on the cell but haven't released yet
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)
        
        if let selectedCell = selectedCell as? CardCollectionViewCell {
            selectedCell.cardSelectedView.isHidden = false
        }
    }
    
    //what happens after you click on cell and release
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCard = cards[indexPath.row]
       
       let selectedCell = collectionView.cellForItem(at: indexPath)
        
        if let selectedCell = selectedCell as? CardCollectionViewCell {
            selectedCell.cardSelectedView.isHidden = true
        }
        KeyedArchiverClient.manager.addCards(selectedCard) { (cardWasSuccessfullySaved) in
            if cardWasSuccessfullySaved {
                self.presentAlertController(title: "SUCCESS", message: "Card was added to your favorites.")
            } else {
                self.presentAlertController(title: "ERROR", message: "Card could not be added.")
            }
        }
    }
}

//datasource
extension CardsViewController: UICollectionViewDataSource {
    
    //how many cells there should be
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    //how to configure a cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath)
        let currentCard = cards[indexPath.row]
        
        guard let cardCell = cell as? CardCollectionViewCell  else {
            //to do - error handling
            return cell
        }
        
        cardCell.cardSelectedView.isHidden = true
        cardCell.nameLabel.text = currentCard.name
        
        //setting image
        if let imageURL = currentCard.imageURLString {
            ImageAPIClient.manager.getImage(from: imageURL, completionHandler: { (onlineImage) in
                cardCell.cardImageView.image = nil
                
                cardCell.cardImageView.image = onlineImage
            }, errorHandler: {print($0)})
        }
        
        return cardCell
    }
    
}

//to use this method, you must assign VC as the delegate
extension CardsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = cardsCollectionView.bounds.height / CGFloat(2)
        let width = cardsCollectionView.bounds.width / CGFloat(2)
        
        return CGSize(width: width, height: height) // this makes the size of the cell equal to the size of the view! overrides any conflicting restraints made in storyboard (like section insets)
    }
}

//search bar delegate
extension CardsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        
        defaults.set(searchText, forKey: searchKey)
        
        searchTerm = searchText
    }
}
