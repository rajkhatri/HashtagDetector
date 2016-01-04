//
//  MainViewController.swift
//  HashtagDetector
//
//  Created by Raj Khatri on 2016-01-03.
//  Copyright © 2016 Raj Khatri. All rights reserved.
//

import UIKit

class MainViewController : UIViewController, UITextViewDelegate {
    
    private var textView:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Hashtag Detector"
        self.automaticallyAdjustsScrollViewInsets = false
        
        initUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if textView != nil {
            textView.becomeFirstResponder()
        }
    }
    
    func initUI() {
        let label = UILabel(frame: CGRectMake(25, 84, CGRectGetWidth(view.frame)-50, 0))
        label.text = "Type into the box below. Use '#' to create a hashtag. A hashtag is space separated."
        label.textColor = .whiteColor()
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        label.sizeToFit()
        view.addSubview(label)
        
        textView = UITextView(frame: CGRectMake(25, CGRectGetMaxY(label.frame)+20, CGRectGetWidth(view.frame)-50, 200))
        textView.delegate = self
        textView.returnKeyType = .Done
        textView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        textView.font = UIFont.systemFontOfSize(15)
        view.addSubview(textView)
        textView.becomeFirstResponder()
        
        let doneLabel = UILabel(frame: CGRectMake(25, CGRectGetMaxY(textView.frame)+20, CGRectGetWidth(view.frame)-50, 25))
        doneLabel.text = "Tap Done to detect tappable hashtags"
        doneLabel.textColor = .whiteColor()
        doneLabel.textAlignment = .Center
        view.addSubview(doneLabel)
    }
    
    func detectHashtags() {
        let hashtagVC = HashtagDetectorViewController()
        hashtagVC.stringToParseForHashtags = textView.text
        self.navigationController?.pushViewController(hashtagVC, animated: true)
    }
    
    // MARK: TextView Delegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            detectHashtags()
            return false
        }
        
        return true
    }
}