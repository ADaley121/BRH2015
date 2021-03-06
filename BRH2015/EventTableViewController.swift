//
//  EventTableViewController.swift
//  BRH2015
//
//  Created by John Hughes on 9/18/15.
//  Copyright (c) 2015 vincentjohnandrew. All rights reserved.
//

import UIKit
import EventKit

class EventTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var events: [EKEvent] = []
    
    var ids = [String]()
    
    var startDateFormat = NSDateFormatter()
    var endDateFormat = NSDateFormatter()
    
    @IBOutlet weak var eventTableView:UITableView!
  
  func reloadEvents() {
    let eventStore = EKEventStore()
    
    switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
    case .Authorized:
      var calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
      if !calendars.isEmpty {
        let predicate = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: NSDate(timeIntervalSinceNow: 86400).dateByAddingTimeInterval(-3600), calendars: calendars)
        println("predicate: \(predicate)")
        if let e = eventStore.eventsMatchingPredicate(predicate) as? [EKEvent] {
          events = []
          ids = []
          for event in e {
            if let calendar = event.calendar, id = event.eventIdentifier {
              events.append(event)
              ids.append(id)
            }
          }
          events = events.reverse()
          ids = ids.reverse()
          eventTableView.reloadData()
        }
      }
    case .Denied:
      println("Access Denied")
    case .NotDetermined:
      println("Status not determined")
    default:
      println("default case")
    }
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        println(KeychainWrapper.stringForKey("auth"))
      if !KeychainWrapper.hasValueForKey("auth") {
        performSegueWithIdentifier("eventToLogin", sender: self)
      }
        
        startDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        startDateFormat.timeStyle = NSDateFormatterStyle.MediumStyle
        startDateFormat.dateFormat = "hh:mm"
        endDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        endDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        endDateFormat.dateFormat = "hh:mm"
      

    }
  
  override func viewDidAppear(animated: Bool) {
    reloadEvents()
  }
  
  override func viewWillDisappear(animated: Bool) {
    events = []
    ids = []
  }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
        let event = events[indexPath.row]
        cell.titleLabel.text = event.title
        cell.locationLabel.text = event.location
        cell.startLabel.text = startDateFormat.stringFromDate(event.startDate)
        cell.endLabel.text = endDateFormat.stringFromDate(event.endDate)
      if let color = UIColor(CGColor: event.calendar.CGColor) {
        cell.vertLine.backgroundColor = color
      }
      
        if event.calendar.title == "Uber" {
          cell.uberImage.hidden = false
        } else {
          cell.uberImage.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let id = ids[indexPath.row]
        if events[indexPath.row].calendar.title == "Uber" {
            self.performSegueWithIdentifier("EventToRequest", sender: id)
        } else {
            self.performSegueWithIdentifier("EventToNew", sender: events[indexPath.row])
        }
      tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventToRequest" {
            var destVC = segue.destinationViewController as! RequestViewController
            let id = sender as! String
            let notif = UILocalNotification()
            notif.userInfo = ["event": id]
            destVC.localNotif = notif
        } else if segue.identifier == "EventToNew" {
            var destVC = segue.destinationViewController as! NewEventViewController
          if let sender = sender as? EKEvent {
            let event = sender
            destVC.event = event
          }
          
            
        }
    }
  
  @IBAction func newNote(sender: UIBarButtonItem) {
    performSegueWithIdentifier("EventToNew", sender: sender)
  }
  
  @IBAction func unwindToMain(sender: UIStoryboardSegue) {
    
  }
}
