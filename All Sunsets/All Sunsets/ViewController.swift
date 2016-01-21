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
    
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var timeNowLabel: UILabel!
    @IBOutlet weak var timeSunsetLabel: UILabel!
    @IBOutlet weak var countdownSunsetLabel: UILabel!
    
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
        
    }
    
    func destroyCoordinates()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("Lat")
        defaults.removeObjectForKey("Lon")
    }
    
    func getCoordinates() -> (Double,Double)
    {
    
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.objectForKey("Lat") != nil
        {
            let lat = defaults.doubleForKey("Lat")
            let lon = defaults.doubleForKey("Lon")
            
            latLabel.text = "Lat: \(lat)"
            longLabel.text = "Long: \(lon)"
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
        dateFormatter.timeStyle = .MediumStyle
        
        let timeString = "\(dateFormatter.stringFromDate(NSDate()))"
        
        timeNowLabel.text = timeString
    }
    
    func secToTime (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func updateCountdown()
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .MediumStyle
        
        let (lat,long) = getCoordinates()
        let sunsetTime = GetSunset(lat, longitude: long)
        let timeUntil = NSDate().timeIntervalSinceDate(sunsetTime)
        let secondsToGo : Int = Int(timeUntil*(-1))
        let (h,m,s) = secToTime(secondsToGo)
        
        var timeString = String(format: "%02d", h) + ":"
            timeString = timeString + String(format: "%02d", m) + ":"
            timeString = timeString + String(format: "%02d", s)
        
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
        dateFormatter.timeStyle = .MediumStyle

        let timeString = "\(dateFormatter.stringFromDate(time))"
        timeSunsetLabel.text = timeString
    }
    
    // Run on load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set coordinates first stime
        let (lat,lon) = getCoordinates()
        latLabel.text = "Lat: \(lat)"
        longLabel.text = "Long: \(lon)"
        
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
    
    @IBAction func updateLocation(sender: AnyObject) {
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
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.alertBody = "Hey you! Yeah you! Swipe to unlock!"
        notification.alertAction = "be awesome!"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    
}

