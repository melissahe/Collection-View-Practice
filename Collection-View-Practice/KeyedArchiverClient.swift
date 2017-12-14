//
//  KeyedArchiverClient.swift
//  Collection-View-Practice
//
//  Created by C4Q on 12/14/17.
//  Copyright © 2017 Melissa He @ C4Q. All rights reserved.
//

import Foundation
import UIKit

//We're just naming it KeyedArchiverClient because it will be dealing with archiving and loading our data using keys

class KeyedArchiverClient {
    private init() {}
    static let manager = KeyedArchiverClient()
    //1. give your plist a name
    static let pathName = "FavoriteCards.plist"
    //2. create an array to store the data you want to be saved
    var cards: [Card] = []
    
    //3. locate the file path of the app's document directory, so you can add the plist there (user generated files are generally kept there)
    
        //returns URL path of the app document folder!
    private func documentDirectory() -> URL {
        //find document folder in the app
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        //return document folder url path
        return paths[0]
    }
    
        //appends a pathName (ex: /Application/Document/(pathName) to the document folder
    func dataFilePath(pathName: String) -> URL {
        //now you can write to the file/pathName you pass in! (if the file doesn't exist, it will create it
        return documentDirectory().appendingPathComponent(pathName)
    }
    
    //4. create functions for saving, loading, adding, and removing cards, getting cards (in the VC)
    
        //get cards
    
    func getCards() -> [Card] {
        return cards
    }
    
        //save cards
    func saveCards() -> Bool {
        //encode the cards into data, so they can be saved with propertylistencoder
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(cards)
            //write this data to the plist
            try data.write(to: dataFilePath(pathName: KeyedArchiverClient.pathName), options: .atomic)
            
            return true
        } catch let error {
            print(error)
            
            return false
        }
        
    }
    
        //load cards
    func loadCards() {
        //decode the data into foundation object (cards)
        let decoder = PropertyListDecoder()
        //find the path where the plist is located
        let path = dataFilePath(pathName: KeyedArchiverClient.pathName)
        
        do {
            //convert plist path into data
            let data = try Data.init(contentsOf: path)
            
            //convert data into cards
            let loadedCards = try decoder.decode([Card].self, from: data)
            
            //load the cards into the cards
            cards = loadedCards
        } catch let error {
            print(error)
        }
    }
    
        //add cards
    func addCards(_ newCard: Card, handler: ((Bool) -> Void)?) {
        cards.append(newCard)
        
        //5. save the cards after adding a new one
        let saveCardCompletion = saveCards()
        
        //completion handler for only if you want to present alert controller in the view controller (you can pass in a handler in the VC) - I did this myself because I wanted an alert controller to appear when saving was successful/unsuccessful
        if let handler = handler {
            handler(saveCardCompletion)
        }
    }
    
    //remove cards
    //to do
    
}

