//
//  HTTPClient.swift
//  JLDishwashers
//
//  Created by Dario Banno on 14/02/2017.
//  Copyright © 2017 AppTown. All rights reserved.
//

import Foundation

enum HTTPRequestMethod: String {
    case get
    case put
    case delete
    case post
}

enum HTTPClientError: Error {
    case invalidRequestURL
    case invalidRequestJSON
    case invalidResponseJSON
    case unexpectedResponseNoData
    case unexpectedResponse(error: Error)
}


struct HTTPClient {
    
    let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func requestData(method: HTTPRequestMethod, path: String, body: Data? = nil, contentType: String? = nil, completion: @escaping (_ result: Data?, _ error: HTTPClientError?) -> ()) {

        Logger.print(">>>>>>>>>> REQUEST")
        Logger.print("method: \(method)")
        Logger.print("path: \(path)")
        Logger.print("body: \(body)")
        
        // Build request
        guard let url = URL(string: path) else {
            Logger.print("-- Error: invalid URL for path \(path).")
            completion(nil, .invalidRequestURL)
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        // Attach JSON body
        if let body = body {
            urlRequest.httpBody = body
        }
        
        if let contentType = contentType {
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        
        // Send request
        urlSession.dataTask(with: urlRequest) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            Logger.print("<<<<<<<<<< RESPONSE")
            Logger.print("Request: \(urlRequest)")
            Logger.print("Status Code: \((response as? HTTPURLResponse)?.statusCode)")
            Logger.print("Response: \(data)")
            
            // Check for error
            guard error == nil else {
                Logger.print("-- Error Response: \(error)")
                completion(nil, .unexpectedResponse(error: error!))
                return
            }
            
            // Data is always expected
            guard let data = data else {
                Logger.print("-- Error: No data.")
                completion(nil, .unexpectedResponseNoData)
                return
            }
            
            // We are cool with data with no content (this is not an error).
            guard data.count > 0 else {
                Logger.print("-- No content.")
                completion(nil, nil)
                return
            }
            
            // Print content
            if let dataString = String(data: data, encoding: .utf8) {
                Logger.print("Content: \(dataString)")
            }
            
            completion(data, nil)
        }.resume()
    }
    
}
