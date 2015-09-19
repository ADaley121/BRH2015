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
    
    @IBOutlet weak var eventTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            if filteredCalendars.isEmpty {
                
            } else {
                
            }
        case .Denied:
            println("Access Denied")
        case .NotDetermined:
            println("Status not determined")
        default:
            println("default case")
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
