//
//  PinterestAPIClient.swift
//  PinterestTest
//
//  Created by Digital Dividend on 19/05/2019.
//  Copyright © 2019 Saad. All rights reserved.
//

import Foundation
import Swift
import UIKit
import SwiftyJSON


//MARK: Enums to use in APIs
///This enum indicates that the API is type of Post, get, put or delete type.
enum httpMethod:String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case del = "DELETE"
}

enum Constant : String{
    case baseURL  = "http://pastebin.com/raw/"
}

///This enum indicates that the result of APIs is what
enum responseState {
    case success
    case failure
    case authError
    case unknown
    case networkIssue
    case timeOut
    case notVarified
}


///this indicates which API is calling and what is it's end point
enum typeOfCall : String{
    case pinterestHomeImages = "wgkJgazE"
}

///this completion block are use as call back from api
typealias completionBlock = (_ state: responseState, _ response : JSON , _ data: Data?) -> Void

///convert string to mutable data
extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true)
        append(data!)
    }
}

struct BaseService{
    // This Will Return Header
    static func getHTTPHeader(params: [String: Any]) -> [String : Any]{
        let headers: [String: Any] = params
        return headers
    }
    
}


///API Router structure which called from another class
struct PinterestAPIClient {
    
    ///get  Lawyer Detail api
    static func getPinterestData( parameters:[String:Any]? , completion: @escaping completionBlock){
        Router.APIRouter(typeCall: .pinterestHomeImages  , parameters: parameters , method: .get, completion: completion)
    }
}



///this router have to perform api tasks
struct Router {
    
    ////this function perform api tasks, defferentiate api tasks with enum typeOfCall, httpsMethods etc
    static func APIRouter(typeCall : typeOfCall, parameters: Dictionary<String, Any>?,urlAppendingValue: String?=nil, method: httpMethod, completion: @escaping completionBlock)
    {
        var urlForAPI = ""
        urlForAPI = Constant.baseURL.rawValue + typeCall.rawValue
        if urlAppendingValue != nil{
            urlForAPI = urlForAPI + urlAppendingValue!
        }
        
        let session = URLSession.shared
        print(urlForAPI)
        
        let escapedAddress = urlForAPI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let timeOut = 30.0
        let request = NSMutableURLRequest(url: URL(string:escapedAddress!)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
        
        request.httpMethod = method.rawValue
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                if error?._code == NSURLErrorTimedOut {
                    completion(.networkIssue,JSON.null, nil)
                }
                else if error?._code == NSURLErrorNotConnectedToInternet || error?._code == NSURLErrorNetworkConnectionLost{
                    completion(.networkIssue,JSON.null, nil)
                }
                else {
                    completion(.unknown,JSON.null, nil)
                }
                return
            }
            
            guard let data = data else {
                completion(.unknown,JSON.null, nil)
                return
            }
            
            do {
                let jsonResult: Any = (try JSONSerialization.jsonObject(with: data, options:
                    JSONSerialization.ReadingOptions.mutableContainers))
                let json = JSON(jsonResult)
                print(json)
            
                // let httpResponse = response as? HTTPURLResponse
                if json["header"]["error"].boolValue == false{
                    completion(.success,json, data)
                }else{
                    completion(.failure,json, data)
                }
                
            } catch _ {
                //                if (response as? HTTPURLResponse)!.url!.absoluteString == Constants.getSetAllPath() || (response as? HTTPURLResponse)!.url!.absoluteString == Constants.getSetAllPathLogin() {
                //                    completion(.authError,JSON.null)
                //                }else{
                completion(.unknown,JSON.null, nil)
                // }
            }
            
        })
        
        task.resume()
    }
    
}
