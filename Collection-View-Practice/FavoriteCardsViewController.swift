//
//  FavoriteCardsViewController.swift
//  Collection-View-Practice
//
//  Created by C4Q on 12/14/17.
//  Copyright © 2017 Melissa He @ C4Q. All rights reserved.
//

import UIKit

class FavoriteCardsViewController: UIViewController {

    
    @IBOutlet weak var favoriteCardsTableView: UITableView!
    
    var cards: [Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteCardsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cards = KeyedArchiverClient.manager.getCards()
        favoriteCardsTableView.reloadData()
    }
}

extension FavoriteCardsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCardCell", for: indexPath)
        let currentCard = cards[indexPath.row]
        
        cell.textLabel?.text = currentCard.name
        
        //set image
        if let imageURL = currentCard.imageURLString {
            ImageAPIClient.manager.getImage(from: imageURL, completionHandler: { (onlineImage) in
                cell.imageView?.image = nil
                cell.imageView?.image = onlineImage
                cell.setNeedsLayout()
                
            }, errorHandler: {print($0)})
        }
        
        return cell
    }
    
}
