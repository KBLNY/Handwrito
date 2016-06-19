//
//  HWHandwrited.swift
//  handwrito
//
//  Created by Kevin on 17/06/16.
//  Copyright © 2016 KBLNY. All rights reserved.
//

import Foundation
import UIKit


/// A Model representing a Handwrited Text.
/// 
/// The handwrited text is a PNG image
class HWRender {
    
    /// The image representing the handwrited text
    var handwritedTextImage: UIImage!
    
    /// Initialize a new Model with the data of the handwrited text image
    ///
    /// - parameters:
    ///   - imageData: the data representing the handwrited text image.
    required init(imageData: NSData) {
        self.handwritedTextImage = UIImage(data: imageData, scale: 1.0)!
    }
    
}