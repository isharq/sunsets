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
    
    
    //    @IBOutlet weak var testlabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var timeNowLabel: UILabel!
    @IBOutlet weak var timeSunsetLabel: UILabel!
    @IBOutlet weak var countdownSunsetLabel: UILabel!

    // initiate core location
    
    func updateCoordinates()
    {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        let currentLocation = locationManager.location?.coordinate
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var lat : Double = 10.0
        var lon : Double = 10.0
        
        
        if (currentLocation!.latitude > 0)
        {
            lat = Double(currentLocation!.latitude)
            lon = Double(currentLocation!.longitude)
        }
        else
        {
            lat = Double(0)
            lon = Double(0)
        }
        
        defaults.setDouble(lat, forKey: "Lat")
        defaults.setDouble(lon, forKey: "Lon")
        
        print("Updated Lat: \(currentLocation!.latitude) Lon: \(currentLocation!.longitude)")
        
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
        
        if let latitude : Double = defaults.doubleForKey("Lat")
        {
            if latitude != 0.0
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
            }
        }
        
        // No latitude found? Let's re-generate it:
        
        updateCoordinates()
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

        var updateTimer: NSTimer!
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerUpdate", userInfo: nil, repeats: true)
    
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
    
}

