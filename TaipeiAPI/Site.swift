//
//  Site.swift
//  TaipeiAPI
//
//  Created by Keith on 2016/5/15.
//  Copyright © 2016年 ChunTaiLin. All rights reserved.
//

import UIKit
import SwiftyJSON

class Site: NSObject {
    var cityName: String?
    var address: String?
    var unit: String?
    var startDate: String?
    var endDate: String?
    var coordinate: [Double]
    
    init(cityName: String, address: String, unit: String, startDate: String, endDate: String, coordinate: [Double]) {
        self.cityName = cityName
        self.address = address
        self.unit = unit
        self.startDate = startDate
        self.endDate = endDate
        self.coordinate = coordinate
    }
    
    init(json:JSON){
        let cityName = json["C_NAME"].string ?? "不明"
        let address = json["ADDR"].string ?? "不明"
        let unit = json["APP_NAME"].string ?? "不明"
        let startDate = json["CB_DA"].string ?? "不明"
        let endDate = json["CE_DA"].string ?? "不明"
        
        let xString = json["X"].stringValue
        let yString = json["Y"].stringValue
        let coordinateArray = SpatialReferenceProjector.TWD97TM2toWGS84(xString, y: yString)
        
        self.cityName = cityName
        self.address = address
        self.unit = unit
        self.startDate = startDate
        self.endDate = endDate
        self.coordinate = coordinateArray
    }
}
