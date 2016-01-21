//
//  ViewController.swift
//  All Sunsets
//
//  Created by Haje Jan kamps on 19/01/2016.
//  Copyright © 2016 Kamps Consulting. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    struct globalVars {
        static var LocationPermissions = true
        static let locationManager = CLLocationManager()
    }
    
    @IBOutlet weak var timeNowLabel: UILabel!
    @IBOutlet weak var timeSunsetLabel: UILabel!
    @IBOutlet weak var countdownSunsetLabel: UILabel!
    @IBOutlet weak var latLonLabel: UILabel!
    @IBOutlet weak var alarmLabel: UILabel!
    
    func updateCoordinates()
    {
        var lat : Double = 1
        var lon : Double = 1

        let defaults = NSUserDefaults.standardUserDefaults()
        
        
            globalVars.locationManager.requestWhenInUseAuthorization()
            globalVars.locationManager.delegate = self
            globalVars.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            
            if  globalVars.locationManager.location?.coordinate == nil
            {
                print("No location fix, setting location to 0 as a hack")
                lat = Double(0)
                lon = Double(0)
            }
            else
            {
                let currentLocation =  globalVars.locationManager.location?.coordinate
                lat = Double(currentLocation!.latitude)
                lon = Double(currentLocation!.longitude)
            }
            
            defaults.setDouble(lat, forKey: "Lat")
            defaults.setDouble(lon, forKey: "Lon")
            // Show what was written
            print("Updated Lat: \(lat) Lon: \(lon)")
            
            // Read back and show
            (lat,lon) = getCoordinates()
            print("Readback: Lat: \(lat) Long: \(lon) ")
        
            latLonLabel.text = String(format: "Lat: %.3f", lat) + String(format: " / Lon: %.3f", lon)
        
        scheduleLocal(self)
        
        
    }
    
    func destroyCoordinates()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("Lat")
        defaults.removeObjectForKey("Lon")
        print("\nCleared Lat and Long")
    }
    
    func getCoordinates() -> (Double,Double)
    {
    
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.objectForKey("Lat") != nil
        {
            let lat = defaults.doubleForKey("Lat")
            let lon = defaults.doubleForKey("Lon")
            return(lat,lon)
        }
        else
        {
            print("No data found, let's try to recreate it...")
            updateCoordinates()
        }
        
        // And now let's grab it from the storage again and return it
        let lat = defaults.doubleForKey("Lat")
        let lon = defaults.doubleForKey("Lon")
        
        return(lat,lon)
        
    }
    
    func updateTime()
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        
        let timeString = "\(dateFormatter.stringFromDate(NSDate()))"
        
        timeNowLabel.text = timeString
    }
    
    func secToTime (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func updateCountdown()
    {
        let (lat,long) = getCoordinates()
        let sunsetTime = GetSunset(lat, longitude: long)
        let timeUntil = NSDate().timeIntervalSinceDate(sunsetTime)
        let secondsToGo : Int = Int(timeUntil*(-1))
        let (h,m,s) = secToTime(secondsToGo)
        
        var timeString = ""
            timeString = "\(h)h"
            timeString = timeString + " \(m)" + "m"
        
        countdownSunsetLabel.text = timeString
    }
    
    func timerUpdate()
    {
            updateTime()
            updateCountdown()
    }
    
    func updateSunsetLabel(time: NSDate)
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle

        let timeString = "\(dateFormatter.stringFromDate(time))"
        timeSunsetLabel.text = timeString
    }
    
    // Run on load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set coordinates first stime
        let (lat,lon) = getCoordinates()
        
        // Set sunset label first time
        let sunsetTime = GetSunset(lat, longitude: lon)
        updateSunsetLabel(sunsetTime)
        
        // Run a timer to keep the clocks up to date.
            let updateTimer: NSTimer!
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerUpdate", userInfo: nil, repeats: true)
        
        
        // Get notification permissions first time
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        // Hide label for now
        alarmLabel.alpha = 0
        
    } // end run on load
    
    func alarmLabel(copy: String){
        alarmLabel.text = copy
        alarmLabel.alpha = 1
        UIView.animateWithDuration(3, animations: {
            self.alarmLabel.alpha = 0
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    @IBAction func updateButton(sender: AnyObject) {
        destroyCoordinates()
    }
    
    // make the status bar pretty
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
        
    }
    
    
    func scheduleLocal(sender: AnyObject) {
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if settings!.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        let notification = UILocalNotification()
        // Clear all existing notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        
        // Set sunset alarm time (10 mins before sunset)
        let (lat,lon) = getCoordinates()
        let sunsetAlarmTime = GetSunset(lat, longitude: lon).dateByAddingTimeInterval((-1)*60*10)
        
        notification.fireDate = sunsetAlarmTime
        notification.alertBody = "Time to go gaze at the sunset!"
        notification.alertAction = "check the time!"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        // Show the user that something happened
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        let timeString = "Alarm set for \(dateFormatter.stringFromDate(sunsetAlarmTime))"
        alarmLabel(timeString)
        
        print("Cleared old, and new notification for \(sunsetAlarmTime)")
        }
    
}

