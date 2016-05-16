//
//  SpatialReferenceProjector.swift
//  TaipeiAPI
//
//  Created by Keith on 2016/5/15.
//  Copyright © 2016年 ChunTaiLin. All rights reserved.
//

import UIKit

class SpatialReferenceProjector: NSObject {
    //MARK: Convert X,Y
    
    class func TWD97TM2toWGS84(x: String, y: String) -> [Double]{
        
        let dx: Double = 250000
        let dy: Double = 0
        let lon0: Double = 121
        let k0: Double = 0.9999
        let a: Double =  6378137.0
        let b: Double = 6356752.314245
        let e: Double = sqrt((1-(b*b)/(a*a)))
        
        let x = Double(x)! - dx
        let y = Double(y)! - dy
        
        // Calculate the Meridional Arc
        let M: Double = y/k0
        
        // Calculate Footprint Latitude
        let mu: Double = M/(a*(1.0 - pow(e, 2)/4.0 - 3*pow(e, 4)/64.0 - 5*pow(e, 6)/256.0))
        let e1: Double = (1.0 - pow((1.0 - pow(e, 2)), 0.5)) / (1.0 + pow((1.0 - pow(e, 2)), 0.5))
        
        let J1: Double = (3*e1/2 - 27*pow(e1, 3)/32.0)
        let J2: Double = (21*pow(e1, 2)/16 - 55*pow(e1, 4)/32.0)
        let J3: Double = (151*pow(e1, 3)/96.0)
        let J4: Double = (1097*pow(e1, 4)/512.0)
        
        let fp1: Double = mu + J1*sin(2*mu) + J2*sin(4*mu)
        let fp2: Double = J3*sin(6*mu) + J4*sin(8*mu)
        let fp: Double = fp1 + fp2
        // Calculate Latitude and Longitude
        
        let e2: Double = pow((e*a/b), 2)
        let C1: Double = pow(e2*cos(fp), 2)
        let T1: Double = pow(tan(fp), 2)
        let R1: Double = a*(1-pow(e, 2))/pow((1-pow(e, 2)*pow(sin(fp), 2)), (3.0/2.0))
        let N1: Double = a/pow((1-pow(e, 2)*pow(sin(fp), 2)), 0.5)
        
        let D: Double = x/(N1*k0)
        
        // lat
        let Q1: Double = N1*tan(fp)/R1
        let Q2: Double = (pow(D, 2)/2.0)
        let Q3: Double = (5 + 3*T1 + 10*C1 - 4*pow(C1, 2) - 9*e2)*pow(D, 4)/24.0
        let Q4: Double = (61 + 90*T1 + 298*C1 + 45*pow(T1, 2) - 3*pow(C1, 2) - 252*e2)*pow(D, 6)/720.0
        let lat: Double = RadiansToDegrees(fp - Q1*(Q2 - Q3 + Q4))
        
        // long
        let Q5: Double = D
        let Q6: Double = (1 + 2*T1 + C1)*pow(D, 3)/6.0
        let Q7: Double = (5 - 2*C1 + 28*T1 - 3*pow(C1, 2) + 8*pow(e2,2) + 24*pow(T1, 2))*pow(D, 5)/120.0
        
        let lon: Double = lon0 + RadiansToDegrees((Q5 - Q6 + Q7)/cos(fp))
        
        let location: NSArray = [lat,lon]
        
        return location as! [Double]
    }
    
    class func DegreesToRadians(degrees: Double) -> Double {
        return degrees * M_PI/180
    }
    
    class func RadiansToDegrees(radians: Double) -> Double {
        return radians * 180/M_PI
    }
}
