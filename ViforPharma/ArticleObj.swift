//
//  ArticleObj.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 5/7/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import SwiftyJSON

class ArticleObj {
    var id: Int!
    var name: String!
    var taId: Int!
    var banner: String!
    var type: String!
    var link: String!
    var createDate: String!
    var articleContent: String!
    var articleLangId: Int!
    
    required init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        taId = json["ta_id"].intValue
        banner = json["banner"].stringValue
        type = json["type"].stringValue
        link = json["link"].stringValue
        createDate = json["created_date"].stringValue
        articleContent = json["article_content"].stringValue
        articleLangId = json["article_lang_id"].intValue
    }
}
