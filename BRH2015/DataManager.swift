//
//  DataManager.swift
//  
//
//  Created by Andrew Daley on 9/19/15.
//
//

import UIKit

enum Router: URLStringConvertible {
  
  case Me
  
  var URLString: String {
    let baseUrl = "https://api.uber.com"
    switch self {
    case .Me:
      return baseUrl + "/v1/me"
    }
  }
}

class DataManager: NSObject {
  
  static let sharedInstance = DataManager()
  
  func updateManagerForAuth() {
    let auth = KeychainWrapper.stringForKey("auth") ?? ""
    let aManager = Manager.sharedInstance
    aManager.session.configuration.HTTPAdditionalHeaders = [
      "Authorization": "Bearer \(auth)" ]
  }
  
  func getProfile(completion: (result: JSON?, error: NSError?) -> ()) {
    updateManagerForAuth()
    request(.GET, Router.Me)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(result: nil, error: error)
        } else if let data: AnyObject = data, json = JSON(rawValue: data) {
          completion(result: json, error: nil)
        }
    }
  }
}
