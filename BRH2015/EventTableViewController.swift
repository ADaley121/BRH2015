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
    
    var startDateFormat = NSDateFormatter()
    var endDateFormat = NSDateFormatter()
    
    let uberLogo: UIImage = UIImage(named: "Uber Logo")!
    
    @IBOutlet weak var eventTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTableView.delegate = self
        eventTableView.dataSource = self
        
        startDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        startDateFormat.timeStyle = NSDateFormatterStyle.MediumStyle
        endDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        endDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
        case .Authorized:
            var calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
            var filteredCalendars = calendars.filter { c in
                if let c = c as? EKCalendar {
                    return c.title == "Uber"
                } else {
                    return false
                }
                } as! [EKCalendar]
            if !calendars.isEmpty {
                let predicate = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: NSDate(timeIntervalSinceNow: 86400).dateByAddingTimeInterval(-3600), calendars: calendars)
                println("predicate: \(predicate)")
                if let e = eventStore.eventsMatchingPredicate(predicate) as? [EKEvent] {
                    self.events = e
                    return events.count
                }
            }
        case .Denied:
            println("Access Denied")
        case .NotDetermined:
            println("Status not determined")
        default:
            println("default case")
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = EventTableViewCell()
        let event = events[indexPath.row]
        cell.titleLabel.text = event.title
        cell.locationLabel.text = event.location
        cell.startLabel.text = startDateFormat.stringFromDate(event.startDate)
        cell.endLabel.text = endDateFormat.stringFromDate(event.endDate)
        if event.calendar.title == "Uber" {
            cell.uberImage.image = uberLogo
        }
        return UITableViewCell()
    }
    
    
}
