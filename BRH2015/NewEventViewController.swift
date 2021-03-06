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
    @IBOutlet weak var notesField: UITextView!
    
    let startDateFormat = NSDateFormatter()
    let startDatePicker = UIDatePicker()
    let endDateFormat = NSDateFormatter()
    let endDatePicker = UIDatePicker()
    
    var event: EKEvent? = nil
  
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
      view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        startDateFormat.timeStyle = NSDateFormatterStyle.MediumStyle
        startDateFormat.dateFormat = "MM/dd hh:mm"
        startDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        startDatePicker.addTarget(self, action: Selector("handleStartDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        startTimeField.inputView = startDatePicker
        
        endDateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        endDateFormat.timeStyle = NSDateFormatterStyle.MediumStyle
        endDateFormat.dateFormat = "MM/dd hh:mm"
        endDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        endDatePicker.addTarget(self, action: Selector("handleEndDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        endTimeField.inputView = endDatePicker
        
        startDatePicker.setDate(NSDate(timeIntervalSinceNow: 0), animated: true)
        startTimeField.text = startDateFormat.stringFromDate(NSDate(timeIntervalSinceNow: 0))
        endDatePicker.setDate(NSDate(timeIntervalSinceNow: 3600), animated: true)
        endTimeField.text = endDateFormat.stringFromDate(NSDate(timeIntervalSinceNow: 3600))
        
        if let e = event {
            self.titleField.text = e.title
            self.locationField.text = e.location
            self.startTimeField.text = startDateFormat.stringFromDate(e.startDate)
            self.endTimeField.text = endDateFormat.stringFromDate(e.endDate)
            self.notesField.text = e.notes
        }
        
    }
    
    func handleStartDatePicker(sender: UIDatePicker) {
        startTimeField.text = startDateFormat.stringFromDate(sender.date)
        if sender.date.compare(endDatePicker.date) == NSComparisonResult.OrderedDescending {
            endTimeField.textColor = UIColor.redColor()
        } else {
            endTimeField.textColor = UIColor.blackColor()
        }
    }
    
    func handleEndDatePicker(sender: UIDatePicker) {
        endTimeField.text = endDateFormat.stringFromDate(sender.date)
        if sender.date.compare(startDatePicker.date) == NSComparisonResult.OrderedAscending {
            endTimeField.textColor = UIColor.redColor()
        } else {
            endTimeField.textColor = UIColor.blackColor()
        }
    }
    
    @IBAction func addEvent(sender: UIBarButtonItem) {
      println("called")
        if titleField.text == "" {
            let alert = UIAlertController(title: "Could Not Save", message: "You must have an event title.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if startDatePicker.date.compare(endDatePicker.date) == NSComparisonResult.OrderedDescending {
            let alert = UIAlertController(title: "Could Not Save", message: "Your event must end after it starts.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let eventStore = EKEventStore()
            println("here")
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
                println(filteredCalendars)
                if filteredCalendars.isEmpty {
                    let newCalendar = EKCalendar(forEntityType: EKEntityTypeEvent, eventStore: eventStore)
                    newCalendar.title = "Uber"
                    println("here2")
                    let sourcesInEventStore = eventStore.sources() as! [EKSource]
                    
                    newCalendar.source = sourcesInEventStore.filter {(source: EKSource) -> Bool in
                        source.sourceType.value == EKSourceTypeLocal.value}.first
                    
                    filteredCalendars.append(newCalendar)
                    var error: NSError? = nil
                    let calendarWasSaved = eventStore.saveCalendar(newCalendar, commit: true, error: &error)
                    println(calendarWasSaved)
                    if !calendarWasSaved {
                        let alert = UIAlertController(title: "Calendar could not save", message: error?.localizedDescription, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alert.addAction(OKAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        NSUserDefaults().setObject(newCalendar.calendarIdentifier, forKey: "EventTrackerPrimaryCalendar")
                    }
                }
                var event = EKEvent(eventStore: eventStore)
                event.calendar = filteredCalendars[0]
                
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
                navigationController?.popViewControllerAnimated(true)
                
            case .Denied:
                println("Access denied")
            case .NotDetermined:
                println("Status not determined")
            default:
                println("Case Default")
            }
          

        }
    }
}
