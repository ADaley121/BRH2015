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
  
  var localNotif: UILocalNotification!
  
  var gmsmarker: GMSMarker?
  
  var userLocation: CLLocation?
  
  var firstLocationUpdate = false
  
  var products: [JSON]? {
    didSet {
      if let products = products where products.count == 0 {
        if products.count == 0 {
          productTextField.enabled = false
          productTextField.text = "Sorry there are no available rides in your area"
        } else {
          productTextField.enabled = true
          selectedProduct = products[0]
        }
      }
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
        } else {
          self.priceLabel.text = ""
        }
      }
    }
  }
  
  var times: [JSON]? {
    didSet {
      if let times = times {
        println("TIMES\(times)")
        if let selectedProduct = selectedProduct {
          let id = selectedProduct["product_id"].stringValue
          for product in times {
            if product["product_id"].stringValue == id {
              self.timeLabel.text = product["estimate"].stringValue + " Seconds"
            }
          }
        } else {
          self.timeLabel.text = ""
        }
      }
    }
  }
  
  var selectedProduct: JSON? {
    didSet {
      if let selectedProduct = selectedProduct {
        productTextField.text = selectedProduct["display_name"].stringValue
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
    
    productTextField.enabled = false
    
    let pickerView = UIPickerView()
    pickerView.delegate = self
    pickerView.dataSource = self
    productTextField.inputView = pickerView
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
    toolbar.items = [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .Done, target: productTextField, action: "resignFirstResponder")]
    productTextField.inputAccessoryView = toolbar
    productTextField.text = "Select a service"
    
    CLLocationManager().requestWhenInUseAuthorization()
    
    NSNotificationCenter.defaultCenter().addObserverForName("both locations", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
      DataManager.sharedInstance.timeEstimate(self.userLocation!.coordinate.latitude, longitude: self.userLocation!.coordinate.longitude) {
        result, error in
        if let result = result {
          if result["times"] != nil {
            self.times = result["times"].arrayValue
          }
        }
      }
      DataManager.sharedInstance.priceEstimate((self.userLocation!.coordinate.latitude, self.userLocation!.coordinate.longitude), end: (self.gmsmarker!.position.latitude, self.gmsmarker!.position.longitude)) { result, error in
        if let result = result {
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
    print("z")
    if let eventID = localNotif.userInfo?["event"] as? String {
      print("a")
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
      if let events = eventStore.eventsMatchingPredicate(predicate) as? [EKEvent] {
        print("b")
        let filteredEvents = events.filter { $0.eventIdentifier == eventID }
        if filteredEvents.count != 0 {
          print("c")
          let event = filteredEvents[0]
          let startDateFormat = NSDateFormatter()
          startDateFormat.dateFormat = "hh:mm"
          navigationItem.title = "\(event.title) (\(startDateFormat.stringFromDate(event.startDate)))"
          if let locationString = event.location where locationString != "" {
            print("d")
            CLGeocoder().geocodeAddressString(locationString) { placemarks, error in
              if let placemarks = placemarks as? [CLPlacemark] where !placemarks.isEmpty {
                print("e")
                self.gmsmarker = GMSMarker(position: placemarks[0].location.coordinate)
                self.gmsmarker!.map = self.mapView
                if let userLocation = self.userLocation {
                  print("f")
                  let bounds = GMSCoordinateBounds(coordinate: self.gmsmarker!.position, coordinate: userLocation.coordinate)
                  self.mapView.camera = GMSCameraPosition(target: userLocation.coordinate, zoom: 14.0, bearing: 0.0, viewingAngle: 50.0)
                  self.mapView.moveCamera(GMSCameraUpdate.fitBounds(bounds))
                  NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "both locations", object: nil))
                } else {
                  self.mapView.camera = GMSCameraPosition(target: self.gmsmarker!.position, zoom: 14.0, bearing: 0.0, viewingAngle: 50.0)
                }
              } else {
                self.locationButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                self.locationButton.setTitle("Provided location invalid. Please enter new location.", forState: .Normal)
              }
            }
          }
        }
      }
      
    }
  }
  
  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    print("g")
    if !firstLocationUpdate {
      print("h")
      firstLocationUpdate = true
      if let location = change[NSKeyValueChangeNewKey] as? CLLocation {
        print("i")
        userLocation = location
        if let gmsmarker = gmsmarker {
          print("j")
          let bounds = GMSCoordinateBounds(coordinate: gmsmarker.position, coordinate: location.coordinate)
          mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 14.0, bearing: 0.0, viewingAngle: 50.0)
          mapView.moveCamera(GMSCameraUpdate.fitBounds(bounds))
          NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "both locations", object: nil))
        } else {
          mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 14.0, bearing: 0.0, viewingAngle: 50.0)
        }
        DataManager.sharedInstance.getProducts(self.userLocation!.coordinate.latitude, longitude: self.userLocation!.coordinate.longitude) { json, error in
          print("k")
          if let json = json {
            print("l")
            println(json)
            if json["products"] != nil {
              self.products = json["products"].arrayValue
            }
          }
        }
      }
      
    }
  }
  
  @IBAction func presentAutocompleteOverlay(sender: UIButton) {
    productTextField.resignFirstResponder()
    let overlayView = AutocompleteOverlayView(frame: view.frame)
    overlayView.delegate = self
    overlayView.animateInto(view)
    overlayView.tableController.userLocation = userLocation
  }
  
  @IBAction func makeRequest(sender: UIButton) {
    if let userLocation = userLocation, gmsmarker = gmsmarker, selectedProduct = selectedProduct {
      DataManager.sharedInstance.makeRequest(selectedProduct["product_id"].stringValue, start: (userLocation.coordinate.latitude, userLocation.coordinate.longitude), end: (userLocation.coordinate.latitude, userLocation.coordinate.longitude)) { result, error in
        if let result = result {
          UIAlertView(title: "Your request was made successfully", message: "Your uber will arrive shortly", delegate: nil, cancelButtonTitle: "Ok").show()
          self.navigationController?.popToRootViewControllerAnimated(true)
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

extension RequestViewController: AutocompleteOverlayViewDelegate {
  
  func overlay(overlay: AutocompleteOverlayView, selectedLocation location: String) {
    overlay.animateOut()
    locationButton.setTitle(location, forState: .Normal)
    locationButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
    CLGeocoder().geocodeAddressString(location) { placemarks, error in
      if let placemarks = placemarks as? [CLPlacemark] where !placemarks.isEmpty {
        println(placemarks)
        self.gmsmarker?.map = nil
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

  func overlayDismissed(overlay: AutocompleteOverlayView) {
    overlay.animateOut()
  }
}
