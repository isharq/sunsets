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
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!

    // initiate core location
    private var locationManager = CLLocationManager()
    
    // Run on load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initiating Location Services
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        print("Ok, finding location")
        
        var currentLocation = locationManager.location?.coordinate
        
        latLabel.text = "Latitude: \(currentLocation!.latitude)"
        longLabel.text = "Longitude: \(currentLocation!.longitude)"
        
        // Calculate sunset
        // based on http://williams.best.vwh.net/sunrise_sunset_algorithm.htm
    
        let zenith = 96.0
        
        let pi = 3.14159265
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        let year    = Double(components.year)
        let month   = Double(components.month)
        let day     = Double(components.day)
        
        var n1 = 0.0
        var n2 = 0.0
        var n3 = 0.0
        var n = 0.0
        
         n1 = floor(275 * month  / 9)
         n2 = floor((month + 9)/12)
         n3 = (1 + floor((year - 4) * floor(year/4) + 2) / 3)
         n = n1 - (n2 * n3) + day - 30


        let lngHour = currentLocation!.longitude / 15
        
        let t = n + ((18-lngHour)/24)
        
        let M = (0.9856 * t) - 3.289
        
        var L = M + (1.916 * sin(M)) + (0.020 * sin(2 * M)) + 282.634
        
        
        // Adjust L into range if required
        if L > 360 { L = L - 360 }
        if L < 0 { L = L + 360 }
        
        var RA = atan(0.91764 * tan(L))
        
        let Lquadrant  = (floor( L/90)) * 90
        let RAquadrant = (floor(RA/90)) * 90
        
        RA = RA + (Lquadrant - RAquadrant)
        
        RA = RA / 15

        let sinDec = 0.39782 * sin(L)
        let cosDec = cos(asin(sinDec))
        
        let myLatitude = currentLocation!.latitude
        
        let cosH = cos(zenith) - (sinDec * sin(myLatitude)) / (cosDec * cos(myLatitude))
    
        print("cosH after creation \(cosH)")

        /*
        if (cosH >  1)
        the sun never rises on this location (on the specified date)
        if (cosH < -1)
        the sun never sets on this location (on the specified date)
        */
        
        print("cosH after convertion \(cosH)")
        
        // this is where it goes wrong
        var H = Double(acos(cosH))
        

        print("H after creation \(H)")

        H = H / 15.0
        
        print("H after division \(H)")
        
        let T = H + RA - (0.06571 * t) - 6.622
        
         print("T \(T)")
        
        var UT = T - lngHour
        
         print("UT just created \(UT)")
        
        // Adjust UT into range if required
        if UT > 24 { UT = UT - 24 }
        if UT < 0 { UT = UT + 24 }
        
         print("UT after logic \(UT)")
        
        
        
        
        // 0 here is time adjustment to local time. The below is UTC
        var localTime = UT + 0.0;
        
        print("localTime \(localTime)")
    
        // END Calculate sunset
    
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

