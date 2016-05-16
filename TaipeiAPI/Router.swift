//
//  Router.swift
//  TaipeiAPI
//
//  Created by Keith on 2016/5/15.
//  Copyright © 2016年 ChunTaiLin. All rights reserved.
//

import UIKit
import Alamofire

enum Router: URLRequestConvertible {
    
    case Map(TaipeiAPI)
    
    static let baseURLString : String = "http://data.taipei/opendata/datalist/apiAccess?"
    
    var method:Alamofire.Method{
        switch self {
        case .Map(let tAPI):
            switch tAPI {
            case .getSite:
                return .GET
            }
        }
    }
    
    var path: String{
        switch self {
        case .Map(let tAPI):
            switch tAPI {
            case .getSite(let idString):
                return "scope=resourceAquire&rid=\(idString)"
            }
        }
    }
    
    var URLRequest: NSMutableURLRequest{
        guard let url = NSURL(string: Router.baseURLString + path) else{
            fatalError("baseURLString cannoot cast to url: \(Router.baseURLString)")
        }
        
        let mutableURLRequest = NSMutableURLRequest(URL: url)
        
        switch self {
        case .Map(let tAPI):
            switch tAPI {
            case .getSite:
                return mutableURLRequest
            }
        }
        
    }
    
    
}

enum TaipeiAPI{
    case getSite(String)
}
