//
//  ViewController.swift
//  BRH2015
//
//  Created by Andrew Daley on 9/18/15.
//  Copyright (c) 2015 vincentjohnandrew. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController {
  
  let clientID = "iiUGtiEYbXfO9NmIuWzKhPo151ExSYdD"
  let clientSecret = "U9qAVLyjouqly7f0MmchANqbQXhfczuT64MruwG9"
  
  @IBOutlet weak var loginButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    loginButton.layer.cornerRadius = 10.0
    loginButton.layer.borderWidth = 2.0
    loginButton.layer.borderColor = UIColor.whiteColor().CGColor
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func loginOAuth(sender: UIButton) {
    
    let oauth = OAuth2Swift(consumerKey: clientID, consumerSecret: clientSecret, authorizeUrl: "https://login.uber.com/oauth/authorize", accessTokenUrl: "https://login.uber.com/oauth/token", responseType: "code", contentType: "multipart/form-data")
    let params = [String:String]()
    let state: String = generateStateWithLength(20) as String
    let redirectURL = "localhost://callback/uber".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    println(redirectURL)
    oauth.authorizeWithCallbackURL( NSURL(string: redirectURL!)!, scope: "request", state: state, success: {
      credential, response, parameters in
        KeychainWrapper.setString(credential.oauth_token, forKey: "auth")
        println(credential.oauth_token)
        self.performSegueWithIdentifier("unwindToEvent", sender: self)
      }, failure: {(error:NSError!) -> Void in
        print(error.localizedDescription, terminator: "")
    })
  }

}

