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
    private var locationManager = CLLocationManager()
    
    func updateTime()
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .MediumStyle
        
        let timeString = "\(dateFormatter.stringFromDate(NSDate()))"
        
        timeNowLabel.text = timeString
    }
    
    func getLatitude(){
        
        let currentLocation = locationManager.location?.coordinate

        
    }
    func getLongitude(){
        
    }
    
    func updateCountdown()
    {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .MediumStyle
        
        // let sunsetTime = GetSunset(getLatitude(), getLongitude())
        
       // var totalWorkTime = NSDate().timeIntervalSinceDate(sunsetTime)
        
        let timeString = "\(dateFormatter.stringFromDate(NSDate()))"

        
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
        
        // Initiating Location Services
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        let currentLocation = locationManager.location?.coordinate
        
        latLabel.text = "Latitude: \(currentLocation!.latitude)"
        longLabel.text = "Longitude: \(currentLocation!.longitude)"
        
        // Run an update on the time
        updateTime()
        
        // Calculate sunset
        
        let sunsetTime = GetSunset(currentLocation!.latitude, longitude: currentLocation!.longitude)
        
        updateSunsetLabel(sunsetTime)
        
        
        
        // END Calculate sunset
        
        var updateTimer: NSTimer!
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerUpdate", userInfo: nil, repeats: true)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func getFixPressed(sender: AnyObject) {
        locationManager.requestLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    
}

