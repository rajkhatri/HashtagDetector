//
//  HashtagDetectorViewController.swift
//  HashtagDetector
//
//  Created by Raj Khatri on 2016-01-03.
//  Copyright © 2016 Raj Khatri. All rights reserved.
//

import UIKit

class HashtagDetectorViewController : UIViewController {
    
    // Must set this var before calling function in order to parse the hashtags
    var stringToParseForHashtags:String?
    
    private var hashtags:Array<String>!
    private var label:UILabel!
    private let kHashTagAttribute = "hashTag"
    private var infoLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .blackColor()
        
        // Make sure box is not empty
        guard stringToParseForHashtags != "" else {
            let vc = UIAlertController(title: "Must enter something in textbox", message: "", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
            vc.addAction(okAction)
            self.presentViewController(vc, animated: true, completion: nil)
            return
        }
        
        initUI()
        
        // 1. Locate hashtags
        // 2. Add tags to hashtags
        // 3. Change color attribute
        // 4. Display in UILabel
        // 5. Let user know how many hashtags were detected.
        
        // Parse hashtags and make links clickable
        parseHashtags()
        if hashtags != nil && hashtags.count > 0 {
            for hashtag in hashtags {
                highlightText(hashtag)
            }
            
            infoLabel.text = "Try tapping on the text above that is in blue color.\nYou can customize the action of the tap on the hashtag.\n\nHashtag Detector has detected \(hashtags.count) hashtag" + (hashtags.count == 1 ? "" : "s")
        }
        else {
            infoLabel.text = "There were no hashtags detected."
        }
        infoLabel.sizeToFit()
    }
    
    func initUI() {
        label = UILabel(frame: CGRectMake(25, 84, CGRectGetWidth(view.frame)-50, 0))
        label.textColor = .whiteColor()
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        label.font = UIFont.systemFontOfSize(15)
        label.attributedText = NSAttributedString(string: stringToParseForHashtags!)
        label.userInteractionEnabled = true
        label.sizeToFit()
        view.addSubview(label)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("labelTapped:"))
        label.addGestureRecognizer(tapGesture)
        
        infoLabel = UILabel(frame: CGRectMake(25, CGRectGetMaxY(label.frame)+40, CGRectGetWidth(view.frame)-50, 0))
        infoLabel.textColor = .whiteColor()
        infoLabel.font = UIFont.systemFontOfSize(15)
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .ByWordWrapping
        view.addSubview(infoLabel)

    }
    
    func parseHashtags() {
        guard let _ = stringToParseForHashtags?.rangeOfString("#") else {
            print("No hashtags in provided text")
            return
        }
        hashtags = [String]()
        findTagWithString(stringToParseForHashtags)
    }
    
    // Recursive Function
    func findTagWithString(str:String?) {
        
        guard let range = str?.rangeOfString("#") else {
            print("No hashtags in provided text")
            return
        }
        
        // Search the text for the beginning "#" and end which is 'charSet' (inverted alphanumeric)
        // By definition, a hashtag can only contain items in the alphanumeric set, so we locate the end of the
        // hashtag by searching for an item in the inverted set
        
        let charSet = NSMutableCharacterSet.alphanumericCharacterSet()
        charSet.invert()
        
        // This will make sure hashtag detection doesn't break when there is a '#' in the middle of words (no space)
        // For example: "#hello#world" is an invalid hashtag, and will be ignored.
        charSet.removeCharactersInString("#")
        
        let endOfHashtag = str?.substringFromIndex(range.startIndex.advancedBy(1)).rangeOfCharacterFromSet(charSet)
        
        var theHashtag:String?
        if endOfHashtag == nil {
            // End of hashtag is the end of the string
            theHashtag = str?.substringFromIndex(range.startIndex.advancedBy(1))
        }
        else {
            // End of hashtag is found
            
            // Get usable string; Remove hashtag; Skip to start of "endOfHashtag" to get hashtag
            theHashtag = str?.substringFromIndex(range.startIndex.advancedBy(1)).substringToIndex(endOfHashtag!.startIndex)
        }
        
        // If valid hastag then add to array
        if theHashtag?.rangeOfString("#") == nil && theHashtag != nil && theHashtag != "" {
            
            // Make sure nothing is before the start of the hashtag
            if str?.substringToIndex(range.endIndex) == "#" {
                addToArray(theHashtag!)
            }
            else {
                let beforeStr = str?.substringWithRange(Range(start: range.startIndex.predecessor(), end: range.startIndex))
                if beforeStr?.rangeOfCharacterFromSet(charSet) != nil {
                    addToArray(theHashtag!)
                }
            }
        }
        
        // Make sure there is more to parse
        guard endOfHashtag != nil else { return }
        
        // Formulate Recursive Parameters
        
        let remainingString = str?.substringFromIndex(range.startIndex.advancedBy(1)).substringFromIndex(endOfHashtag!.endIndex)
        
        if remainingString?.characters.count > 0 {
            findTagWithString(remainingString)
        }
    }
    
    func addToArray(var theHashtag:String) {
        
        if !theHashtag.containsString("#") {
            theHashtag = "#" + theHashtag
        }
        
        hashtags.append(theHashtag)
        print("Found valid hashtag: \(theHashtag)")
    }
    
    // MARK: Highlight
    func highlightText(text:String) {
        
        let origText = NSString(format: "%@", label.attributedText!.string)
        let range:NSRange = origText.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch)
        
        if range.location != NSNotFound {
            let blueTint = UIColor(red: 0, green: 155.0/255.0, blue: 255.0/255.0, alpha: 1)
            let str:NSMutableAttributedString = NSMutableAttributedString(attributedString: label.attributedText!)
            
            // Loop through to find all occurences of the text
            var searchRange = NSMakeRange(0, str.length)
            var foundRange:NSRange?
            
            while (range.location < str.length) {
                
                searchRange.length = str.length - searchRange.location
                foundRange = origText.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch, range: searchRange)
                
                if foundRange?.location != NSNotFound {
                    // Found an occurrence of the substring
                    
                    // New location to search is where the last one was found
                    searchRange.location = foundRange!.location + foundRange!.length
                    
                    var isValidHashtag:Bool = false
                    let charSet = NSMutableCharacterSet.alphanumericCharacterSet()
                    charSet.invert()
                    charSet.removeCharactersInString("#")
                    
                    // Check character Before and After to ensure valid hashtag
                    
                    // Before Check
                    if foundRange!.location == 0 {
                        // The start of string
                        isValidHashtag = true
                    }
                    else {
                        // Assure that the character before is one of the delimitted characters
                        let charBefore:NSString = origText.substringWithRange(NSMakeRange(foundRange!.location-1, 1))
                        let beforeRange = charBefore.rangeOfCharacterFromSet(charSet)
                        
                        if beforeRange.location != NSNotFound {
                            isValidHashtag = true
                        }
                    }
                    
                    // After Check
                    if isValidHashtag && foundRange!.location + foundRange!.length == origText.length {
                        // Make sure the before is valid
                        // Check if length of string matches range searched
                        isValidHashtag = true
                    }
                    else if isValidHashtag {
                        // Assure that the character after is one of the delimitted characters
                        let charAfter:NSString = origText.substringWithRange(NSMakeRange(foundRange!.location + foundRange!.length, 1))
                        let afterRange = charAfter.rangeOfCharacterFromSet(charSet)
                        
                        isValidHashtag = (afterRange.location != NSNotFound)
                    }
                    
                    if isValidHashtag {
                        // Add the color attribute to the foundRange
                        str.addAttribute(NSForegroundColorAttributeName, value: blueTint, range: foundRange!)
                        
                        // This is used when detecting taps on this range
                        // We are storing the text for this range as an attribute
                        str.addAttribute(kHashTagAttribute, value: text, range: foundRange!)
                    }
                }
                else {
                    break
                }
            }
            label.attributedText = str
        }
    }
    
    // MARK: Tap Events
    func labelTapped(tapGesture:UITapGestureRecognizer) {
        let attributedText = NSMutableAttributedString(attributedString: label.attributedText!)
        attributedText.appendAttributedString(NSAttributedString(string: " "))
        attributedText.addAttribute(NSFontAttributeName, value: label.font, range: NSMakeRange(0, attributedText.length))
        
        // Using NSTextStorage/NSLayoutManager/NSTextContainer to determine location tapped
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        // Determine location tapped
        let location = tapGesture.locationInView(label)
        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // Get the attributes of the location tapped
        // We have saved the value of the hashtag inside the attribute of the label in the hashtags range in the string
        if characterIndex < textStorage.length {
            let range = NSRangePointer()
            let attributes = textStorage.attributesAtIndex(characterIndex, effectiveRange: range)
            
            guard let hashtag = attributes[kHashTagAttribute] as? NSString else { return }
            if hashtag.length > 0 {
                UIAlertView(title: "Hashtag tapped:", message: hashtag as String, delegate: nil, cancelButtonTitle: "Ok").show()
                print("Hashtag Tapped: \(hashtag)")
            }
        }
        
        // Note: The label should be "sizeToFit()" or properly aligned to the top of the label in order for this to work
        // having a larger area with gap above and below the text in a UILabel, will require additional rework in this function to determine the exact tap area
    }
}