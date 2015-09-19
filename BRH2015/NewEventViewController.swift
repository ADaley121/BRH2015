//
//  NewEventViewController.swift
//  BRH2015
//
//  Created by John Hughes on 9/18/15.
//  Copyright (c) 2015 vincentjohnandrew. All rights reserved.
//

import UIKit
import EventKit

class NewEventViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    
    let startDateFormat = NSDateFormatter()
    let startDatePicker = UIDatePicker()
    let endDateFormat = NSDateFormatter()
    let endDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        startDateFormat.timeStyle = NSDateFormatterStyle.MediumStyle
        startDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        startDatePicker.addTarget(self, action: Selector("updateStartField:"), forControlEvents: UIControlEvents.ValueChanged)
        startTimeField.inputView = startDatePicker
        
        endDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        endDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        endDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        endDatePicker.addTarget(self, action: Selector("updateEndField:"), forControlEvents: UIControlEvents.ValueChanged)
        endTimeField.inputView = endDatePicker
        
    }
    
    
    
    @IBAction func addEvent(sender: UIButton) {
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
        case .Authorized:
            let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
                as! [EKCalendar]
            for calendar in calendars {
                if calendar.title == "Uber" {
                    var event = EKEvent(eventStore: eventStore)
                    event.calendar = calendar
                    
                    event.title = titleField.text
                    event.location = locationField.text
                    event.startDate = startDatePicker.date
                    event.endDate = endDatePicker.date
                    event.notes = notesField.text
                    
                    // Save Event in Calendar
                    var error: NSError?
                    let result = eventStore.saveEvent(event, span: EKSpanThisEvent, error: &error)
                    
                    if result == false {
                        if let theError = error {
                            println("An error occured \(theError)")
                        }
                    }
                }
            }
        case .Denied:
            println("Access denied")
        case .NotDetermined:
            println("Status not determined")
        default:
            println("Case Default")
        }
    }

}
