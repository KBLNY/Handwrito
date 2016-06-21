//
//  HWFontAPIManager.swift
//  handwrito
//
//  Created by Kevin on 21/06/16.
//  Copyright © 2016 KBLNY. All rights reserved.
//

import Foundation
import Alamofire // HTTP Requests
import SwiftyJSON // JSON Parsing


/// This represent an error in the process of getting a font.
/// The error could be:
/// - `RateLimitExceededError` for rate limit exceeded
/// - `GenericError` for any other king of error
enum HWFontError : ErrorType {
    case GenericError
    case RateLimitExceededError
}


/// This is a type used by the call to get a font list. This is composed of an array of `HWFont` type if the operation succeed, and of a `HWFontError` in case of error
typealias ServiceResponseGetFonts = (Array<HWFont>?, HWFontError?) -> Void


/// A class handling the API calls to handle font calls
class HWFontAPIManager: NSObject {
    
    /// Singleton
    static let sharedInstance = HWFontAPIManager()
    
    
    /// Endpoint to render a handwrited text to a PNG image
    let GET_HANDWRITINGS_ENDPOINT = "/handwritings"
    
    
    /// Get an array of font
    ///
    /// - parameters:
    ///   - limit: the maximum number of font to fetch.
    ///   - offset: the number of font to be skipped by the fetch
    ///   - onCompletion: a completion callback to handle the success or error result
    func getHandwritings(limit: Int, offset: Int, onCompletion: ServiceResponseGetFonts) {
        
        // Define the URL endpoint
        let requestUrl = HWConfig.HANDWRITING_API_URL + GET_HANDWRITINGS_ENDPOINT
        
        // Build the array of parameters
        let params = [
            "limit" : limit,
            "offset": offset,
            ]
        
        // Automatically validates status code within 200...299 range, and that the Content-Type header of the response matches the Accept header of the request
        Alamofire.request(.GET, requestUrl, parameters: params, encoding: .URLEncodedInURL, headers: self.getHTTPHeaderForAuthorization())
            .validate() // Test the response is between 200 and 299
            .responseJSON { response in
                
                // If success, execute onCompletion callback with an array of HWFont Model
                // If failed, execute onCompletion callback with an HWHandwriteError error
                switch response.result {
                case .Success(let data):
                    // Get a JSON Object from the data
                    let json = JSON(data)
                    
                    // Create model to return
                    var fontList = Array<HWFont>()
                    
                    for _font in json.array! {
                        if let _id = _font["id"].string {
                            if let _title = _font["title"].string {
                                let font = HWFont(id: _id, title: _title)
                        
                                fontList.append(font)
                            }
                        }
                    }
                    
                    // execute completion block as return
                    onCompletion(fontList, nil)
                    
                case .Failure(let error):
                    if let statusCode = error.userInfo["StatusCode"] as? Int {
                        if statusCode == 429 {
                            onCompletion(nil, HWFontError.RateLimitExceededError)
                        }
                    }
                    onCompletion(nil, HWFontError.GenericError)
                }
                
        }
    }
    
    
    // TODO func getRenderText to PDF
    
    
    /// Get the HTTP header required to call the Handwriting.io API
    ///
    /// - returns: An array of key-value for each header, containing the Authorization HTTP Header.
    private func getHTTPHeaderForAuthorization() -> [String: String] {
        let loginString = NSString(format: "%@:%@", HWConfig.HANDWRITING_API_KEY, HWConfig.HANDWRITING_API_SECRET)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions([])
        
        let headers = [
            "Authorization": "Basic \(base64LoginString)"
        ]
        
        return headers
    }
    
}
