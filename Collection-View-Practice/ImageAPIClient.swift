//
//  ImageAPIClient.swift
//  Collection-View-Practice
//
//  Created by C4Q on 12/14/17.
//  Copyright © 2017 Melissa He @ C4Q. All rights reserved.
//

import Foundation
import UIKit

class ImageAPIClient {
    private init() {}
    static let manager = ImageAPIClient()
    func getImage(from urlString: String, completionHandler: @escaping (UIImage) -> Void, errorHandler: @escaping (Error) -> Void) {
        guard let url = URL(string: urlString) else {
            errorHandler(AppError.badImageURL(url: urlString))
            
            return
        }
        
        let request = URLRequest(url: url)
        
        NetworkHelper.manager.performDataTask(with: request, completionHandler: { (data) in
            guard let image = UIImage(data: data) else {
                print("bad image data")
                return
            }
            
            completionHandler(image)
        }, errorHandler: errorHandler)
    }
}
