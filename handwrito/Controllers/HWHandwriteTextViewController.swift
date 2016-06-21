//
//  HWHandwriteTextViewController.swift
//  handwrito
//
//  Created by Kevin on 17/06/16.
//  Copyright © 2016 KBLNY. All rights reserved.
//

import UIKit
import Dodo // Message Bar Alert
import SwiftValidator // Validation System
import SDWebImage // Image Caching


/// A ViewController responsible for handling the tranformation of an input text into a handwrited text
class HWHandwriteTextViewController: UIViewController, ValidationDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
 

    /// Validator to validate user inputs
    private let validator = Validator()
    private var fontDataSource = Array<HWFont>()
    private var fontImageDataSource = Array<UIImage>()
    private var selectedFontId: String = ""
    
    
    // MARK: UI Objects
    
    /// The text to transform into a handwrited text
    @IBOutlet weak var textToHandwrite: UITextView!
    
    /// The button to process the transformation
    @IBOutlet weak var handwriteProcessingButton: UIButton!
    
    /// The image representing the handwrited text
    @IBOutlet weak var handwritedTextImage: UIImageView!
    
    /// A loader notifying the process is running
    @IBOutlet weak var imageLoader: UIActivityIndicatorView!

    /// A picker to select a font for the render of the text
    @IBOutlet weak var pickerFont: UIPickerView!
    
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the most rated font (simulated, take the first 20)
        self.initPickerFont()
        
        // Init the message bar for presenting error messages
        self.initMessageBarAlert()
        
        // Init Validation
        self.initValidator()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Layout
    

    
    // MARK: User Interaction
    
    /// Validate the user's input. If success, it triggers `validationSuccessful()`, otherwise `validationFailed()`
    ///
    /// - parameters:
    ///   - sender: the button that triggered the action.
    @IBAction func handwriteProcessButton_onTouchUpInside(sender: UIButton) {
        // Validate the field, if pass call API to transform text into handwrite text, otherwise, show an error message
        validator.validate(self)
    }
    
    
    
    // MARK: UIPickerViewDataSource & UIPickerViewDelegate
    
    // Used for simple text in picker
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        let _font = self.fontDataSource[row]
//        return _font.title
//    }
    
    
    // Used to display the font name style with its own font
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        // get the 
        let _fontImage = self.fontImageDataSource[row]
        
        let fontImageView = UIImageView(image: _fontImage)
        
        return fontImageView
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.fontImageDataSource.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let _font = self.fontDataSource[row]
        
        // When a font is selected, keep its id as selected
        self.selectedFontId = _font.id
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    
    
    
    // MARK: ValidationDelegate
    
    /// Trigger if the ValidationDelegate's `validation` succeed.
    /// It will call the API to get the user's input text as a handwrited text
    func validationSuccessful() {
        // Display a loader
        self.imageLoader.startAnimating()
        
        // All fields are validated, call the API to transform the user's input text into a handwrited text
        HWHandwriteTextAPIManager.sharedInstance.getRenderText(self.textToHandwrite.text!, fontId: self.selectedFontId, color: "#FFFFFF", fontSize: "24px", height: "500px") { (renderObject: HWRender?, error: HWHandwriteError?) in
            // In any case, stop the loader
            self.imageLoader.stopAnimating()
            
            guard error == nil else {
                // An error occured display an error message
                self.handleError(error!)
                return
            }
            
            guard renderObject != nil else {
                // If the render object is nil, An error occured display an error message
                self.showErrorAlert("An error occured")
                return
            }
            
            // Display the generated result image
            self.handwritedTextImage.image = renderObject!.handwritedTextImage
        }
    }
    
    /// Trigger if the ValidationDelegate's `validation` failed.
    /// It will display all the error at the screen
    /// - parameters:
    ///   - errors: An array of all errors got by the `validate` step.
    func validationFailed(errors: [(Validatable, ValidationError)]) {
        // Default error message
        var errorMessage: String = "An error occured. Please fixed:"
        
        // Consolidate all errors found into 1 message
        for (field, error) in validator.errors {
            errorMessage += "\n" + error.errorMessage
        }
        
        // And display this consolidated error message
        self.showErrorAlert(errorMessage)
    }
    
    
    
    // MARK: Additional Helpers
    
    /// Initialize the error message alert system
    private func initMessageBarAlert() {
        // Set the text color
        self.view.dodo.style.label.color = UIColor.whiteColor()
        
        // Close the bar after 3 seconds
        self.view.dodo.style.bar.hideAfterDelaySeconds = 5
        
        // Close the bar when it is tapped
        self.view.dodo.style.bar.hideOnTap = true
        
        // Use a built-in icon
        view.dodo.style.rightButton.icon = .Close

        // Change button's image color
        view.dodo.style.rightButton.tintColor = DodoColor.fromHexString("#FFFFFF90")
        
        // Close the bar when the button is tapped
        view.dodo.style.rightButton.hideOnTap = true
    }
    
    /// Show an error with the error message alert system
    /// - parameters:
    ///   - errorMessage: The error message to show
    private func showErrorAlert(errorMessage: String) {
        // Display an error message
        self.view.dodo.error(errorMessage)
    }
    
    /// Initialize a validator to validate user's input
    private func initValidator() {
        // Build a chartset composed of letters (lower and upper, without accents), digits, punctuation and whitespace and new line
        let charset = NSMutableCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopq‌​rstuvwxyz")
        charset.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        charset.formUnionWithCharacterSet(NSCharacterSet.decimalDigitCharacterSet())
        charset.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())

        
        // Register the text to transform field for its validation
        validator.registerField(textToHandwrite, rules: [
            RequiredRule(message: "Please type a text to transform"),
            CharacterSetRule(characterSet: charset, message: "Please type only alphanumeric characters"),
            MaxLengthRule(length: 9000, message: "The text must be at most 9000 characters long"),
            MinLengthRule(length: 1, message: "The text must be at least 1 character long")
            ]
        )
    }
    
    
    private func initPickerFont() {
        self.pickerFont.delegate = self
        self.pickerFont.dataSource = self
        
        // All fields are validated, call the API to transform the user's input text into a handwrited text
        HWFontAPIManager.sharedInstance.getHandwritings(20, offset: 0) { (fontList: Array<HWFont>?, error: HWFontError?) in
            guard error == nil else {
                // An error occured display an error message
                self.handleErrorFont(error!)
                return
            }
            
            guard fontList != nil else {
                // If the render object is nil, An error occured display an error message
                self.showErrorAlert("An error occured")
                return
            }
            
            // Set the Data source
            self.fontDataSource = fontList!
            
            // Set the selected font as the first one
            if let firstFont = fontList?.first {
                self.selectedFontId = firstFont.id
            }
            
            for _font in fontList! {
                self.getFontNameStyleByItsOwnFont(_font)
            }
        }

    }
    
    
    private func getFontNameStyleByItsOwnFont(font: HWFont) {
        // All fields are validated, call the API to transform the user's input text into a handwrited text
        HWHandwriteTextAPIManager.sharedInstance.getRenderText(font.title, fontId: font.id, color: "#000000", fontSize: "20px", height: "30px", width: "\(self.pickerFont.frame.width)px") { (renderObject: HWRender?, error: HWHandwriteError?) in
            guard error == nil else {
                // An error occured display an error message
                self.handleError(error!)
                return
            }
            
            guard renderObject != nil else {
                // If the render object is nil, An error occured display an error message
                self.showErrorAlert("An error occured")
                return
            }
            
            // Display the generated result image
            self.fontImageDataSource.append(renderObject!.handwritedTextImage)
            
            // Refresh the font picker
            self.pickerFont.reloadAllComponents()
        }
        
    }
    

    
    
    /// Display an error message according to its type
    /// - parameters:
    ///   - error: The error to handle
    private func handleError(error: HWHandwriteError) {
        var errorMessage = "An error occured"
        
        switch error {
        case .HWUnsupportedCharacterError:
            errorMessage = "You entered an unsupported character, please try again"
            break
        case .RateLimitExceededError:
            errorMessage = "Rate Limit Exceeded"
            break
        default:
            errorMessage = "An error occured"
        }
        
        self.showErrorAlert(errorMessage)
    }
    
    
    /// Display an error message according to its type
    /// - parameters:
    ///   - error: The error to handle
    private func handleErrorFont(error: HWFontError) {
        var errorMessage = "An error occured"
        
        switch error {
        case .RateLimitExceededError:
            errorMessage = "Rate Limit Exceeded"
            break
        default:
            errorMessage = "An error occured"
        }
        
        self.showErrorAlert(errorMessage)
    }
    
}