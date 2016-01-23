import UIKit
import CoreLocation


    func  deg_to_rad(x: Double) -> Double
    {
        return (M_PI / 180.0) * x;
    }
    
    func  rad_to_deg(x: Double) -> Double
    {
        return (180.0 / M_PI) * x;
    }
    
    func  deg_sin(x: Double) -> Double
    {
        return sin(deg_to_rad(x));
    }
    
    func  deg_asin(x: Double) -> Double
    {
        return rad_to_deg(asin(x));
    }
    
    func  deg_atan(x: Double) -> Double
    {
        return rad_to_deg(atan(x));
    }
    
    func  deg_tan(x: Double) -> Double
    {
        return tan(deg_to_rad(x));
    }
    
    func  deg_cos(x: Double) -> Double
    {
        return cos(deg_to_rad(x));
    }
    
    func  deg_acos(x: Double) -> Double
    {
        return rad_to_deg(acos(x));
    }
    
    func normalize_range(v: Double, max: Double) -> Double
    {
        var variable = v
        while (variable < 0) {
            variable += max;
        }
        
        while (variable >= max) {
            variable -= max;
        }
        
        return variable;
    }
    
    
    // START SUNSET FUNCTION
    
func GetSunset(latitude:Double, longitude:Double) -> NSDate {
        let inDate = NSDate()
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let zenith : Double = 90
        
        let components = calendar.components([.Year, .Month, .Day, .TimeZone] , fromDate: inDate)
        
        //    1. first calculate the day of the year
        //
        let N1 = floor(275.0 * Double(components.month) / 9.0)
        let N2 = floor((Double(components.month) + 9.0) / 12.0)
        let N3 = (1.0 + floor((Double(components.year) - 4.0 * floor(Double(components.year) / 4.0) + 2.0) / 3.0))
        let N = N1 - (N2 * N3) + Double(components.day) - 30.0
        
        // Grab location based on phone location
//        let latitude = currentLocation!.latitude
//        let longitude = currentLocation!.longitude
        
        let lngHour : Double = longitude / 15.0
    
        var t : Double
            t = N + ((18.0 - lngHour) / 24)
        
        //3. calculate the Sun's mean anomaly
        //
        //M = (0.9856 * t) - 3.289
        //
        
        let M = (0.9856 * t) - 3.289
        
        //4. calculate the Sun's true longitude
        var L : Double = M + (1.916 * deg_sin(M)) + (0.020 * deg_sin(2 * M)) + 282.634;
        L = normalize_range(L, max: 360);
        
        
        //5a. calculate the Sun's right ascension
        var RA : Double = deg_atan(0.91764 * deg_tan(L));
        RA = normalize_range(RA, max: 360);
        
        
        //5b. right ascension value needs to be in the same quadrant as L
        let Lquadrant  = (floor( L/90.0)) * 90.0
        let RAquadrant = (floor(RA/90.0)) * 90.0
        RA = RA + (Lquadrant - RAquadrant)
        
        //5c. right ascension value needs to be converted into hours
        RA = RA / 15.0
        
        
        //6. calculate the Sun's declination
        let sinDec = 0.39782 * deg_sin(L);
        let cosDec = deg_cos(deg_asin(sinDec));
        
        
        //7a. calculate the Sun's local hour angle
        let cosH : Double = (deg_cos(zenith) - (sinDec * deg_sin(latitude))) / (cosDec * deg_cos(latitude));
        
        if(cosH > 1.0){
            print("Will not rise in this location!")
        }
        
        if(cosH < -1.0){
            print("Will not set in this location!")
        }
        
        //7b. finish calculating H and convert into hours
        var H : Double;
        
            H = deg_acos(cosH);
        
        H = H / 15.0;
        
        
        //8. calculate local mean time of rising/setting
        
        let T = H + RA - (0.06571 * t) - 6.622;
        
        
        //9. adjust back to UTC
        let UT = normalize_range(T - lngHour, max: 24.0);
    
    
        //10. convert UT value to local time zone of latitude/longitude
        
        let timezone : NSTimeZone = components.timeZone!
        let localSeconds : Double = Double(timezone.secondsFromGMTForDate(inDate))
        let localOffset : Double =   localSeconds / 3600.0
        let localT = UT + localOffset
        
        // convert to an NSDate
        let hour = trunc(localT)
        let hourSeconds = 3600 * (localT - hour)
        let minute = hourSeconds / 60
        let second = hourSeconds - (minute * 60)
        
        components.hour = Int(hour)
        components.minute = Int( minute) ;
        components.second = Int(second)
        
        var sunset = calendar.dateFromComponents(components)!
    
        if sunset.timeIntervalSince1970 < inDate.timeIntervalSince1970
        {
            sunset = sunset.dateByAddingTimeInterval(24*3600)
        }
    
        return sunset
    } // end function