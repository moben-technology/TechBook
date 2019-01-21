//
//  Sector.swift
//  TechBook
//
//  Created by MacBook on 21/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import Foundation

class Sector: NSObject {
    
    var _id : String?
    var nameSector : String?
    
    override init() {}
    
    // Parse Request
    init(_ dic : [String : Any])
    {
        if let _id = dic["_id"] as! String? {
            self._id = _id
        }
        if let _nameSector = dic["nameSector"] as! String? {
            self.nameSector = _nameSector
        }
        
    }
    
}
