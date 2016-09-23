//
//  Constant.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 20/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import Foundation

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}

// MARK: - Debug constants
let IS_DEBUG = true
let URL_TYPE = "URL"
let PDF_TYPE = "PDF"

// MARK: - Store data key constants
let USER_ID_KEY = "user_id"
let USER_TA_KEY = "user_ta"
let USER_PRIMARY_LANGUAGE_KEY = "user_primary_lang"
let USER_SECONDARY_LANGUAGE_KEY = "user_secondary_lang"

let MENU_POS = "menu_position"

let FILTER_TA = "list_ta_filter"
let FILTER_LANG = "list_language_filter"

let VIEW_FAVOURITES = "view_favourites"

let ARTICLE_ID = "article_id"
let ARTICLE_LANG_ID = "article_lang_id"

let LANGUAGES_SAVE = "language_items_save"

// MARK: - Api constants
let LOGIN_API: String = "login"
let GET_SUBSCRIBE_TA_API: String = "getSubscribeTA"
let GET_LANGUAGE_API: String = "getLanguage"
let SET_TA_API: String = "setSubscribeTA"
let SET_PRIMARY_LANG_API: String = "setPrimaryLanguage"
let SET_SECONDARY_LANG_API: String = "setSecondaryLanguage"
let GET_FAVOURITE_API: String = "getFavouriteArticles"
let GET_ARTICLE_API: String = "getArticlesFilter"
let GET_ARTICLE_DETAIL_API: String = "getArticleDetail"
let SET_FAVOURITE_API: String = "setFavourite"
let REMOVE_FAVOURITE_API: String = "removeFavourite"











// MARK: - Message
let CONNECTION_ERROR = "Cannot connect to server."
let CHECK_INPUT_SELECT_TA = "Please subscribe your TA"
let CHECK_INPUT_SELECT_LANGUAGE = "Please select your language"
let SAVE_SUCCESS = "Save successfull!"