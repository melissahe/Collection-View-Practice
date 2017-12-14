//
//  NetworkHelper.swift
//  Collection-View-Practice
//
//  Created by C4Q on 12/14/17.
//  Copyright © 2017 Melissa He @ C4Q. All rights reserved.
//

import Foundation

enum AppError: Error {
    case badURL(url: String)
    case badImageURL(url: String)
    case badStatusCode(code: Int)
    case cannotParseJson(rawError: Error)
    case noInternet
    case other(rawError: Error)
}

class NetworkHelper {
    private init() {}
    static let manager = NetworkHelper()
    let session = URLSession(configuration: .default)
    func performDataTask(with request: URLRequest, completionHandler: @escaping (Data) -> Void, errorHandler: @escaping (Error) -> Void) {
        session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error as? URLError {
                    switch error {
                    case URLError.notConnectedToInternet:
                        errorHandler(AppError.noInternet)
                    default:
                        errorHandler(AppError.other(rawError: error))
                    }
                    
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    errorHandler(AppError.badStatusCode(code: response.statusCode))
                }
                
                if let data = data {
                    
                    //optional for printing data - won't work for images
                    if let dataString = String(data: data, encoding: .utf8) {
                        print(dataString)
                    }
                    
                    completionHandler(data)
                }
            }
        }.resume()
    }
}
