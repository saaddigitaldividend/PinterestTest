//
//  PinterestModel.swift
//  PinterestTest
//
//  Created by Digital Dividend on 19/05/2019.
//  Copyright © 2019 Saad. All rights reserved.
//

import Foundation
import SwiftyJSON

class PinterestModel{
    
    typealias pinterestCompletion = (Bool, [BaseClass]?, String) -> Void

    static func getPinterestList(completion: @escaping pinterestCompletion){
        
        PinterestAPIClient.getPinterestData(parameters: nil) { (response, json,data) in
            PinterestModel.parseResult(status: response, json: json, data: data! , completion: { (status, model, message) in
                completion(status,model,message)
            })
        }
        
        
    }
    
    
    // Mark: - parsing The Inisight Result
    static func parseResult(status: responseState, json: JSON, data: Data, completion: pinterestCompletion) {
        
        if status == .success{
            print("JSON: \(json)")
            
            if let pinterest = json.array{
                if pinterest.count > 0{
                    
                    do{
                        let base = try JSONDecoder().decode([BaseClass].self, from: data)
                        print("Link: \(base[0].urls?.regular ?? "Opps Empty Value")")
                        completion(true, base, Constants.successMessage)
                    }
                    catch let error{
                        print("Error: \(error)")
                        completion(false,nil,error.localizedDescription)
                    }
                    
                }else{
                    completion(false,nil,Constants.failureMessage)
                }
            }
        }
        else {
           completion(false,nil,Constants.failureMessage)
        }
    }
    
    // Convert from JSON to nsdata
    static func jsonToNSData(json: JSON) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
    
    static func convertJSONToString(json: JSON, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
    
}
