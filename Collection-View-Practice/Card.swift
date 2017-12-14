//
//  Card.swift
//  Collection-View-Practice
//
//  Created by C4Q on 12/14/17.
//  Copyright © 2017 Melissa He @ C4Q. All rights reserved.
//

import Foundation

struct ResultsWrapper: Codable {
    let cards: [Card]
}

struct Card: Codable {
    let name: String
    let text: String?
    let imageURLString: String?
    
    static let testCards: [Card] = [
       
    ]
    
    enum CodingKeys: String, CodingKey {
        case name, text
        case imageURLString = "imageUrl"
    }
}

class CardAPIClient {
    private init() {}
    static let manager = CardAPIClient()
    func getCards(from urlString: String, completionHandler: @escaping ([Card]) -> Void, errorHandler: @escaping (Error) -> Void) {
        
        guard let url = URL(string: urlString) else {
            errorHandler(AppError.badURL(url: urlString))
            
            return
        }
        
        let request = URLRequest(url: url)
        
        NetworkHelper.manager.performDataTask(
            with: request,
            completionHandler: { (data) in
                do {
                    let results = try JSONDecoder().decode(ResultsWrapper.self, from: data)
                    
                    completionHandler(results.cards)
                } catch let error {
                    errorHandler(AppError.cannotParseJson(rawError: error))
                }
        },
            errorHandler: errorHandler)
    }
}
