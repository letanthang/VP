//
//  RestApiManager.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 13/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    // Local server
//    let baseURL = "http://192.168.1.88/index.php/api/"
    
    let baseURL = "http://54.254.163.18/viforpharma/index.php/api/"
    
    func callApi(_ path: String, body: String, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + path
        makeHTTPPostRequest(route, body: body, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    // MARK: Perform a GET Request
    fileprivate func makeHTTPGetRequest(_ path: String, onCompletion: @escaping ServiceResponse) {
        let request = NSMutableURLRequest(url: URL(string: path)!)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json:JSON = JSON(data: jsonData)
                onCompletion(json, error as NSError?)
            } else {
                onCompletion(nil, error as NSError?)
            }
        })
        task.resume()
    }
    
    
    // MARK: Perform a POST Request
    fileprivate func makeHTTPPostRequest(_ path: String, body: String, onCompletion: @escaping ServiceResponse) {
        let request = NSMutableURLRequest(url: URL(string: path)!)
        
        // Set the method to POST
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        
        // Set the POST body for the request
        let postData: Data = body.data(using: String.Encoding.ascii, allowLossyConversion: true)!
        request.httpBody = postData
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json:JSON = JSON(data: jsonData)
                onCompletion(json, nil)
            } else {
                onCompletion(nil, error as NSError?)
            }
        })
        task.resume()
        
    }
}
