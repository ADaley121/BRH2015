//
//  PlaceholderTextView.swift
//  
//
//  Created by Andrew Daley on 9/20/15.
//
//

import UIKit

@IBDesignable class PlaceholderTextView: UITextView {
  
  private var placeholderLabel: UILabel?
  
  @IBInspectable var placeholderColor: UIColor = UIColor.lightGrayColor()
  
  @IBInspectable var placeholder: String = ""
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "myTextDidChange", name: UITextViewTextDidChangeNotification, object: self)
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "myTextDidChange", name: UITextViewTextDidChangeNotification, object: self)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if placeholderLabel == nil {
      placeholderLabel = UILabel(frame: CGRect(x: 8, y: 8, width: frame.width - 16, height: 20))
      addSubview(placeholderLabel!)
    }
    if let placeholderLabel = placeholderLabel {
      placeholderLabel.textColor = placeholderColor
      placeholderLabel.font = font
      placeholderLabel.text = placeholder
      bringSubviewToFront(placeholderLabel)
    }
  }
  
  func myTextDidChange() {
    if let placeholderLabel = placeholderLabel {
      placeholderLabel.hidden = text != ""
    }
  }
}