//
//  HWFont.swift
//  handwrito
//
//  Created by Kevin on 21/06/16.
//  Copyright © 2016 KBLNY. All rights reserved.
//

import Foundation
import UIKit


/// A Model representing a Font of the handwriting.io.
///
/// The font is a set of fields, not a ttf file
class HWFont {
    
    /// The unique identifier of the font
    var id: String!
    
    /// The name of the font
    var title: String!
    
    
    /// Initialize a new Model representing a hanwriting.io font
    ///
    /// - parameters:
    ///   - id: the unique identifier of the hanwriting.io font
    ///   - title: the name of the hanwriting.io font
    required init(id: String, title: String) {
        self.id = id
        self.title = title
    }
    
}