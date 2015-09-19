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
  
  @IBOutlet weak var eventNameLabel: UILabel!
  
  @IBOutlet weak var productTextField: UITextField!
  
  @IBOutlet weak var locationButton: UIButton!
  
  var localNotif: UILocalNotification = {
    let localNotifi = UILocalNotification()
    localNotifi.fireDate = NSDate(timeInterval: -900, sinceDate: NSDate())
    localNotifi.alertTitle = "HELLO happens in 15 minutes!"
    localNotifi.alertBody = "Remember to book an uber to get you to the event!"
    localNotifi.alertAction = "Ok"
    localNotifi.userInfo = ["event": "EAA3388D-A8F7-4692-9E07-4C768EFC2788:3F37F844-7496-4011-B19D-A188E60F3E54"]
    localNotifi.soundName = UILocalNotificationDefaultSoundName
    localNotifi.applicationIconBadgeNumber = 1
    return localNotifi
  }()
  
  var gmsmarker: GMSMarker?
  
  var userLocation: CLLocation?
  
  var firstLocationUpdate = false
  
  var products: [JSON]? {
    didSet {
      let pickerView = UIPickerView()
      pickerView.delegate = self
      pickerView.dataSource = self
      productTextField.inputView = pickerView
      let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
      toolbar.items = [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .Done, target: productTextField, action: "resignFirstResponder")]
      productTextField.inputAccessoryView = toolbar
    }
  }
  
  var prices: [JSON]? {
    didSet {
      if let prices = prices {
        if let selectedProduct = selectedProduct {
          let id = selectedProduct["product_id"].stringValue
          for product in prices {
            if product["product_id"].stringValue == id {
              self.priceLabel.text = product["estimate"].stringValue
            }
          }
        }
      }
    }
  }
  
  var times: [JSON]? {
    didSet {
      if let times = times {
        if let selectedProduct = selectedProduct {
          let id = selectedProduct["product_id"].stringValue
          for product in times {
            if product["product_id"].stringValue == id {
              self.timeLabel.text = product["estimate"].stringValue + " Seconds"
            }
          }
        }
      }
    }
  }
  
  var selectedProduct: JSON? {
    didSet {
      if let selectedProduct = selectedProduct {
        if let times = times {
          let id = selectedProduct["product_id"].stringValue
          for product in times {
            if product["product_id"].stringValue == id {
              self.timeLabel.text = product["estimate"].stringValue + " Seconds"
            }
          }
        }
        if let prices = prices {
          let id = selectedProduct["product_id"].stringValue
          for product in prices {
            if product["product_id"].stringValue == id {
              self.priceLabel.text = product["estimate"].stringValue
            }
          }
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    productTextField.text = "Select a service"
    
    CLLocationManager().requestWhenInUseAuthorization()
    
    NSNotificationCenter.defaultCenter().addObserverForName("both locations", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
      DataManager.sharedInstance.timeEstimate(self.userLocation!.coordinate.latitude, longitude: self.userLocation!.coordinate.longitude) {
        result, error in
        if let result = result {
          println(result)
          if result["times"] != nil {
            self.times = result["times"].arrayValue
          }
        }
      }
      DataManager.sharedInstance.priceEstimate((self.userLocation!.coordinate.latitude, self.userLocation!.coordinate.longitude), end: (self.gmsmarker!.position.latitude, self.gmsmarker!.position.longitude)) { result, error in
        if let result = result {
          println(result)
          if result["prices"] != nil {
            self.prices = result["prices"].arrayValue
          }
        }
      }
    })
    
    mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
    dispatch_async(dispatch_get_main_queue(), {
      self.mapView.myLocationEnabled = true
    })
    mapView.myLocationEnabled = true
    
    if let eventID = localNotif.userInfo?["event"] as? String {
      println("id " + eventID)
      let eventStore = EKEventStore()
      var calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
      let filteredCalendars = calendars.filter { calendar in
        if let calendar = calendar as? EKCalendar {
          return calendar.title == "Uber"
        } else {
          return false
        }
      } as! [EKCalendar]
      let predicate = eventStore.predicateForEventsWithStartDate(NSDate(timeInterval: -600, sinceDate: NSDate()), endDate: NSDate(timeIntervalSinceNow: 86400), calendars: filteredCalendars)
      var events = eventStore.eventsMatchingPredicate(predicate) as! [EKEvent]
      events = events.filter { $0.eventIdentifier == eventID }
      if events.count != 0 {
        let event = events[0]
        println(event.location)
        println(event.startDate)
        println(event.calendar?.calendarIdentifier)
        println(event.notes)
        println(event.title)
        println(event.startDate)
        self.eventNameLabel.text = event.title
        if let locationString = event.location where locationString != "" {
          println("loc" + locationString)
          CLGeocoder().geocodeAddressString(locationString) { placemarks, error in
            if let placemarks = placemarks as? [CLPlacemark] where !placemarks.isEmpty {
              println(placemarks)
              self.gmsmarker = GMSMarker(position: placemarks[0].location.coordinate)
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
        DataManager.sharedInstance.getProducts(self.userLocation!.coordinate.latitude, longitude: self.userLocation!.coordinate.longitude) { json, error in
          if let json = json {
            if json["products"] != nil {
              self.products = json["products"].arrayValue
            }
          }
        }
      }
      
    }
  }
  
}

extension RequestViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return (products ?? []).count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return (products ?? [])[row]["display_name"].stringValue
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    productTextField.text = (products ?? [])[row]["display_name"].stringValue
    selectedProduct = (products ?? [])[row]
  }
}
