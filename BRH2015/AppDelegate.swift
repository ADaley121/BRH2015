//
//  AppDelegate.swift
//  BRH2015
//
//  Created by Andrew Daley on 9/18/15.
//  Copyright (c) 2015 vincentjohnandrew. All rights reserved.
//

import UIKit
import OAuthSwift
import EventKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    EKEventStore().requestAccessToEntityType(EKEntityTypeEvent) { success, error in
      if success {
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
      }
    }
    
    let notifTypes = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert;
    let notifSettings = UIUserNotificationSettings(forTypes: notifTypes, categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(notifSettings)
    
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  // TODO: remove objects when handling local notifs
  func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    println("background fetch")
    let eventStore = EKEventStore()
    var calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
    let filteredCalendars = calendars.filter { calendar in
      if let calendar = calendar as? EKCalendar {
        return calendar.title == "Uber"
      } else {
        return false
      }
    } as! [EKCalendar]
    if !calendars.isEmpty {
      let predicate = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: NSDate(timeIntervalSinceNow: 86400), calendars: calendars)
      if let events = eventStore.eventsMatchingPredicate(predicate) as? [EKEvent] {
        var processed: [String]
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("already pushed") as? NSData {
          processed = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String]
        } else {
          processed = []
        }
        let filteredEvents = events.filter { event in
          processed.filter { $0 == event.eventIdentifier }.count == 0
        }
        for event in filteredEvents {
          let localNotif = UILocalNotification()
          localNotif.fireDate = NSDate(timeInterval: -900, sinceDate: event.startDate)
          localNotif.alertTitle = "\(event.title) happens in 15 minutes!"
          localNotif.alertBody = "Remember to book an uber to get you to the event!"
          localNotif.alertAction = "Ok"
          localNotif.userInfo = ["event": event.eventIdentifier]
          localNotif.soundName = UILocalNotificationDefaultSoundName
          localNotif.applicationIconBadgeNumber = 1
          UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
          processed.append(event.eventIdentifier)

        }
        println(UIApplication.sharedApplication().scheduledLocalNotifications)
        let newData = NSKeyedArchiver.archivedDataWithRootObject(processed)
        NSUserDefaults.standardUserDefaults().setValue(newData, forKey: "already pushed")
      }
    }
    completionHandler(UIBackgroundFetchResult.NewData)
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    println("here")
    if (url.host == "callback") {
      println(url)
      NSNotificationCenter.defaultCenter().addObserverForName("OAuthSwiftCallbackNotificationName", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in println("herehy381bi3")})
      OAuth2Swift.handleOpenURL(url)
    }
    return true
  }
  
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    // TODO: Handle Local notifs
  }


}

