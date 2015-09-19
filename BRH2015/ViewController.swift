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

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
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
    oauth.authorizeWithCallbackURL( NSURL(string: redirectURL!)!, scope: "profile", state: state, success: {
      credential, response, parameters in
        KeychainWrapper.setString(credential.oauth_token, forKey: "auth")
        DataManager.sharedInstance.getProfile { result, error in
          println(error)
          println(result)
        }
      }, failure: {(error:NSError!) -> Void in
        print(error.localizedDescription, terminator: "")
    })
  }

}

