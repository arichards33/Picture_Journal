//
//  Networking.swift
//  Picture Journal
//
//  Created by Alex Richards on 5/1/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import Foundation
import UIKit

class Networking {
    
    static let shared = Networking()
    
    private init(){}
    
    func getWeather(url: String, completion:@escaping (Weather?) -> Void) {
        
        guard let url = NSURL(string: url) else {
            fatalError("Unable to create NSURL from string")
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            print("Res: \(String(describing: response)))")
            print("Data: \(String(describing: data))")
            
            guard error == nil else {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
                
            }
            
            
            do {
                let decoder = JSONDecoder()
                let temperatures = try decoder.decode(Weather.self, from: data)
                completion(temperatures)
            } catch {
                print("Error serializing/decoding JSON: \(error)")
            }
        })
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        
        task.resume()
    }
    
    
    
}

