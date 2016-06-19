//
//  HWValidatableUITextView.swift
//  handwrito
//
//  Created by Kevin on 18/06/16.
//  Copyright © 2016 KBLNY. All rights reserved.
//

import SwiftValidator


/// An extension to `SwiftValidator` in order to make `UITextView` validatable
extension UITextView: Validatable {

    /// The text to validate
    public var validationText: String {
        return text ?? ""
    }
}
