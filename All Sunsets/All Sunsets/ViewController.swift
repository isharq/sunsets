//
//  ViewController.swift
//  All Sunsets
//
//  Created by Haje Jan Kamps on 19/01/2016.
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
    
    
    //
    //  FUNCTIONS DEALING WITH COORDINATES
    //
    
    // This function uses the location service to grab the current coordinates, before writing it to NSUserDefaults.
    func updateCoordinates()
    {
        var lat : Double = 1
        var lon : Double = 1

        let defaults = NSUserDefaults.standardUserDefaults()
        
        globalVars.locationManager.requestWhenInUseAuthorization()
        globalVars.locationManager.delegate = self
        globalVars.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        // If there's no location fix, write Lat / Long to zero, as a hack to avoid the app crashing later. There's probably a better way of doing this.
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
        
        // Write the lat/long to a couple of defaults called Lat and Long.
        defaults.setDouble(lat, forKey: "Lat")
        defaults.setDouble(lon, forKey: "Lon")
        
        // Show what was written at the terminal, for a sense-check
        print("Updated Lat: \(lat) Lon: \(lon)")
            
        // Read back and show what was read at the terminal, for a sense-check
        (lat,lon) = getCoordinates()
        print("Readback: Lat: \(lat) Long: \(lon) ")
    
        // Update the LatLong Label in the UI to aid troubleshooting.
        latLonLabel.text = String(format: "Lat: %.3f", lat) + String(format: " / Lon: %.3f", lon)
        
        // And finally, schedule the alarm to go off later.
        scheduleLocal(self)
    }
    
    // This unction simply clears the Lat & Long from the user defaults.
    func destroyCoordinates()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("Lat")
        defaults.removeObjectForKey("Lon")
        print("\nCleared Lat and Long")
    }
    
    // This function grabs the coordinates from the User Defaults storage - or, if there is no storage (for example, if the app is freshly installed, or the user cleared the storage to force a refresh) It returns Lat Long as two Doubles.
    func getCoordinates() -> (Double,Double)
    {
        let defaults = NSUserDefaults.standardUserDefaults()

        // Check if the data exists. If it does; pull it and return it.
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
    
    
    //
    //  FUNCTIONS FOR UPDATING LABELS ON THE SCREEN
    //
    
    // This function takes a number of seconds and returns hours, minutes, seconds as three integers.
    func secToTime (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    // Function formats and updates the timeNowLabel text.
    func updateTime()
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        
        let timeString = "\(dateFormatter.stringFromDate(NSDate()))"
        timeNowLabel.text = timeString
    }

    // Function calculates how many hours and minutes are left until sunset, writes it to the label
    func updateCountdown()
    {
        let (lat,long) = getCoordinates()
        
        // Runs the GetSunset function and returns a time for the sunset
        let sunsetTime = GetSunset(lat, longitude: long)
        
        // Finds out how long it is until sunset
        let timeUntil = NSDate().timeIntervalSinceDate(sunsetTime)
        
        // The function returns a 'date since', so to get a 'date until', I need to multiply by -1
        let secondsToGo : Int = Int(timeUntil*(-1))
        
        // Return as a sensibe format
        let (h,m,s) = secToTime(secondsToGo)
        
        // Create and write string
        var timeString = ""
            timeString = "\(h)h"
            timeString = timeString + " \(m)" + "m"
        
        countdownSunsetLabel.text = timeString
    }
    
    // Function checks the time for the next sunset, then writes it to the UI
    func updateSunsetLabel()
    {
        // Calculate
        let (lat,lon) = getCoordinates()
        let sunsetTime = GetSunset(lat, longitude: lon)
        
        // Format
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        
        // Output
        let timeString = "\(dateFormatter.stringFromDate(sunsetTime))"
        timeSunsetLabel.text = timeString
    }
    
    // This is the function that gets called by the timer; it runs every second
    func timerUpdate()
    {
            updateTime()
            updateCountdown()
            updateSunsetLabel()
    }
    

    //
    // RUNTIME FUNCTIONS
    //
    
    
    // Run on load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set coordinates first stime
        let (lat,lon) = getCoordinates()

        // Initialise labels in the UI, so users have a chance of seeing what it's for.
        timeSunsetLabel.text        = "Sunset Time"
        timeNowLabel.text           = "Time Now"
        countdownSunsetLabel.text   = "Countdown"
        
        // Run a timer to keep the clocks up to date.
            let updateTimer: NSTimer!
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerUpdate", userInfo: nil, repeats: true)
        
        // Get notification permissions first time
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        // Hide label for now - we have nothing to show on it yet.
        alarmLabel.alpha = 0
        
    } // end run on load

    
    // Updates the Alarm Label with an animation that fades after 5 seconds
    func alarmLabel(copy: String){
        alarmLabel.text = copy
        alarmLabel.alpha = 1
        UIView.animateWithDuration(5.0, animations: {self.alarmLabel.alpha = 0})
    }
    
    // Deal with memory outage warnings
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Run when update completes in location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        destroyCoordinates()
    }
    
    // Run when error happens in location
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    // Run the Destroy Coordinates function when a user clicks the button
    @IBAction func updateButton(sender: AnyObject) {
        destroyCoordinates()
    }
    
    // make the status bar pretty
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //
    // NOTIFICATION FUNCTION
    //
    
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

