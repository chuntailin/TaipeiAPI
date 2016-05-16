//
//  ServerManager.swift
//  TaipeiAPI
//
//  Created by Keith on 2016/5/15.
//  Copyright © 2016年 ChunTaiLin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ServerManager: NSObject {
    class func getSites(idString id:String, completion:(sites:[Site]) -> Void, failure:(error:NSError?) -> Void){
        
        let api = Router.Map(TaipeiAPI.getSite(id))
        
        Alamofire.request(api).responseJSON { (response) in
            switch response.result{
            case .Success(let value):
                guard let jsonArray = JSON(value)["result"]["results"].array else{
                    print("ServerManager: Cannot cast getSites response json to array type")
                    //在這裡可以給自己定義好的ErrorType
                    failure(error: nil)
                    return
                }
                
                var sites = [Site]()
                
                jsonArray.forEach({ (json) in
                    let site = Site(json: json)
                    sites.append(site)
                })
                
                completion(sites: sites)
                
            case .Failure(let error):
                failure(error: error)
            }
        }
    }
}
