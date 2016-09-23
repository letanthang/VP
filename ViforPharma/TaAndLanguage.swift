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
        let id = aDecoder.decodeInteger(forKey: "id")
        let name = aDecoder.decodeObject(forKey: "name") as! String
        
        self.init(id: id, name: name)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
    }
}
