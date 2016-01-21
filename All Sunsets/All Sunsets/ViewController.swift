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
    
    func getCoordinates() -> CLLocationCoordinate2D
    {
        let locationManager = CLLocationManager()

        // Initiating Location Services
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        
        let currentLocation = locationManager.location?.coordinate
        return currentLocation!
        
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
        
        let sunsetTime = GetSunset(getCoordinates().latitude, longitude: getCoordinates().longitude)
        
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
        
        
        latLabel.text = "Latitude: \(getCoordinates().latitude)"
        longLabel.text = "Longitude: \(getCoordinates().longitude)"
        
        // Run an update on the time
        updateTime()
        
        // Calculate sunset
        
        let sunsetTime = GetSunset(getCoordinates().latitude, longitude: getCoordinates().longitude)
        
        updateSunsetLabel(sunsetTime)
        
        
        
        // END Calculate sunset
        
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
    
    
    
}

