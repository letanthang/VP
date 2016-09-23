//
//  TaAndLanguage.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 24/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import SwiftyJSON

class TaAndLanguageObj: NSObject, NSCoding {
    var id: Int!
    var name: String!
    
    required init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeIntegerForKey("id")
        let name = aDecoder.decodeObjectForKey("name") as! String
        
        self.init(id: id, name: name)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
    }
}
