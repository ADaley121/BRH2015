//
//  DataManager.swift
//  
//
//  Created by Andrew Daley on 9/19/15.
//
//

import UIKit

enum Router: URLStringConvertible {
  
  
  case Products
  case Product(Int)
  case PriceEstimate
  case TimeEstimate
  
  
  case Me
  case Request
  
  var URLString: String {
    let baseUrl = "https://api.uber.com/v1/"
    let ext: String = {
      switch self {
      case .Products:
        return "products"
      case .Product(let id):
        return "products/\(id)"
      case .PriceEstimate:
        return "estimates/price"
      case .TimeEstimate:
        return "estimate/time"
        
      case .Me:
        return "me"
      case .Request:
        return "requests"
      }
    }()
    return baseUrl + ext
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
  
  func getProducts(latitude: Double, longitude: Double, completion: (result: JSON?, error: NSError?) -> ()) {
    request(.GET, Router.Products, parameters: ["latitude": latitude, "longitude": latitude], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(result: nil, error: error)
        } else if let data: AnyObject = data, json = JSON(rawValue: data) {
          completion(result: json, error: nil)
        }
    }
  }
  
  func getProductByID(id: Int, completion: (result: JSON?, error: NSError?) -> ()) {
    request(.GET, Router.Product(id), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(result: nil, error: error)
        } else if let data: AnyObject = data, json = JSON(rawValue: data) {
          completion(result: json, error: nil)
        }
    }
  }
  
  func priceEstimate(start: (lat: Double, long: Double), end: (lat: Double, long: Double), completion: (result: JSON?, error: NSError?) -> ()) {
    request(.GET, Router.PriceEstimate, parameters: ["start_latitude": start.lat, "start_longitude": start.long, "end_latitude": end.lat, "end_longitude": end.long], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(result: nil, error: error)
        } else if let data: AnyObject = data, json = JSON(rawValue: data) {
          completion(result: json, error: nil)
        }
    }
  }
  
  func timeEstimate(latitude: Double, longitude: Double, completion: (result: JSON?, error: NSError?) -> ()) {
    request(.GET, Router.TimeEstimate, parameters: ["start_latitude": latitude, "start_longitude": longitude], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(result: nil, error: error)
        } else if let data: AnyObject = data, json = JSON(rawValue: data) {
          completion(result: json, error: nil)
        }
    }
  }
  
  func makeRequest(productID: String, start: (lat: Double, long: Double), end: (lat: Double, long: Double), completion: (result: JSON?, error: NSError?) -> ()) {
    updateManagerForAuth()
    request(.GET, Router.TimeEstimate, parameters: ["product_id": productID, "start_latitude": start.lat, "start_longitude": start.long, "end_latitude": end.lat, "end_longitude": end.long], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(result: nil, error: error)
        } else if let data: AnyObject = data, json = JSON(rawValue: data) {
          completion(result: json, error: nil)
        }
    }
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
