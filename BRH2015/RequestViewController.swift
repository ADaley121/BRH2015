//
//  RequestViewController.swift
//  
//
//  Created by Andrew Daley on 9/19/15.
//
//

import UIKit
import EventKit
import GoogleMaps

class RequestViewController: UIViewController {
  
  @IBOutlet weak var mapView: GMSMapView!
  
  @IBOutlet weak var priceLabel: UILabel!
  
  @IBOutlet weak var timeLabel: UILabel!
  
  var localNotif: UILocalNotification = {
    let localNotifi = UILocalNotification()
    localNotifi.fireDate = NSDate(timeInterval: -900, sinceDate: NSDate())
    localNotifi.alertTitle = "HELLO happens in 15 minutes!"
    localNotifi.alertBody = "Remember to book an uber to get you to the event!"
    localNotifi.alertAction = "Ok"
    localNotifi.userInfo = ["event": "EAA3388D-A8F7-4692-9E07-4C768EFC2788:4413E7AA-DF40-4EDD-9DB0-EF78C2B3559E"]
    localNotifi.soundName = UILocalNotificationDefaultSoundName
    localNotifi.applicationIconBadgeNumber = 1
    return localNotifi
  }()
  
  var gmsmarker: GMSMarker?
  
  var userLocation: CLLocation?
  
  var firstLocationUpdate = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    CLLocationManager().requestWhenInUseAuthorization()
    
    NSNotificationCenter.defaultCenter().addObserverForName("both locations", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
      DataManager.sharedInstance.timeEstimate(self.userLocation!.coordinate.latitude, longitude: self.userLocation!.coordinate.longitude) {
        result, error in
        if let result = result {
          println(result)
          // TODO:
        }
      }
      DataManager.sharedInstance.priceEstimate((self.userLocation!.coordinate.latitude, self.userLocation!.coordinate.longitude), end: (self.gmsmarker!.position.latitude, self.gmsmarker!.position.longitude)) { result, error in
        if let result = result {
          println(result)
          // TODO:
        }
      }
    })
    
    mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
    dispatch_async(dispatch_get_main_queue(), {
      self.mapView.myLocationEnabled = true
    })
    mapView.myLocationEnabled = true
    
    if let eventID = localNotif.userInfo?["event"] as? String {
      println("id" + eventID)
      if let event = EKEventStore().eventWithIdentifier(eventID) {
        println("ev \(event)")
        if let locationString = event.location where locationString != "" {
          println("loc" + locationString)
          CLGeocoder().geocodeAddressString(locationString) { placemarks, error in
            if let placemarks = placemarks where !placemarks.isEmpty {
              println(placemarks)
              self.gmsmarker = GMSMarker(position: placemarks[0].coordinate)
              self.gmsmarker!.map = self.mapView
              if let userLocation = self.userLocation {
                let bounds = GMSCoordinateBounds(coordinate: self.gmsmarker!.position, coordinate: userLocation.coordinate)
                self.mapView.camera = GMSCameraPosition(target: userLocation.coordinate, zoom: 14.0, bearing: 0.0, viewingAngle: 50.0)
                self.mapView.moveCamera(GMSCameraUpdate.fitBounds(bounds))
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "both locations", object: nil))
              } else {
                self.mapView.camera = GMSCameraPosition(target: self.gmsmarker!.position, zoom: 14.0, bearing: 0.0, viewingAngle: 50.0)
              }
            }
          }
        }
      }
    }
  }
  
  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    if !firstLocationUpdate {
      firstLocationUpdate = true
      if let location = change[NSKeyValueChangeNewKey] as? CLLocation {
        userLocation = location
        if let gmsmarker = gmsmarker {
          let bounds = GMSCoordinateBounds(coordinate: gmsmarker.position, coordinate: location.coordinate)
          mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 14.0, bearing: 0.0, viewingAngle: 50.0)
          mapView.moveCamera(GMSCameraUpdate.fitBounds(bounds))
          NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "both locations", object: nil))
        } else {
          mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 14.0, bearing: 0.0, viewingAngle: 50.0)
        }
        
      }
      
    }
  }
  
}
