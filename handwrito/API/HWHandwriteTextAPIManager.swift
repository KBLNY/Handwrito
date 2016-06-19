//
//  HWHandwriteTextAPIManager.swift
//  handwrito
//
//  Created by Kevin on 17/06/16.
//  Copyright © 2016 KBLNY. All rights reserved.
//

import Foundation
import Alamofire


/// This represent an error in the process of rendering a handwriting text.
/// The error could be:
/// - `RateLimitExceededError` for rate limit exceeded
/// - `HWUnsupportedCharacterError` for unsupported character
/// - `GenericError` for any other king of error
enum HWHandwriteError : ErrorType {
    case GenericError
    case RateLimitExceededError
    case HWUnsupportedCharacterError
}


/// This is a type used by the call to render a handwrited text. This is composed of a `HWRender` type if the operation succeed, and of a `HWHandwriteError` in case of error
typealias ServiceResponseRender = (HWRender?, HWHandwriteError?) -> Void


/// A class handling the API calls to render a handwrited text
class HWHandwriteTextAPIManager: NSObject {
    
    /// Singleton
    static let sharedInstance = HWHandwriteTextAPIManager()
    
    
    /// Endpoint to render a handwrited text to a PNG image
    let RENDER_PNG_ENDPOINT = "/render/png"
    
    
    /// Render an input text to a handwrited text as a PNG Image
    ///
    /// - parameters:
    ///   - text: the text to transform into a handwrited text image.
    ///   - onCompletion: a completion callback to handle the success or error result
    func getRenderText(text: String, onCompletion: ServiceResponseRender) {
        // TODO add font type, font size, and color as parameters
        
        // Define the URL endpoint
        let requestUrl = HWConfig.HANDWRITING_API_URL + RENDER_PNG_ENDPOINT
        
        // Build the array of parameters
        let params = [
            "handwriting_id" : "2D5QW0F80001", //molly
            "text": text,
            "handwriting_size": "24px", // 0px - 9000px
            "handwriting_color": "#FFFFFF",
        ]
        
        // Automatically validates status code within 200...299 range, and that the Content-Type header of the response matches the Accept header of the request
        Alamofire.request(.GET, requestUrl, parameters: params, encoding: .URLEncodedInURL, headers: self.getHTTPHeaderForAuthorization())
            .validate() // Test the response is between 200 and 299
            .responseData { response in
                
                // If success, execute onCompletion callback with a HWRender Model
                // If failed, execute onCompletion callback with an HWHandwriteError error
                switch response.result {
                case .Success:
                    if (response.data != nil) {
                        // Create model to return
                        onCompletion(HWRender(imageData: response.data!), nil)
                    } else {
                        onCompletion(nil, HWHandwriteError.GenericError)
                    }
                case .Failure(let error):
                    if let statusCode = error.userInfo["StatusCode"] as? Int {
                        if statusCode == 400 {
                            onCompletion(nil, HWHandwriteError.HWUnsupportedCharacterError)
                        } else if statusCode == 429 {
                            onCompletion(nil, HWHandwriteError.RateLimitExceededError)
                        }
                    }
                    onCompletion(nil, HWHandwriteError.GenericError)
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
