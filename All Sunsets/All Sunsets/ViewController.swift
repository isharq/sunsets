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

