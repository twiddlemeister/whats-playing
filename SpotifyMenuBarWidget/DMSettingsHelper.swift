//
//  DMSettingsHelper.swift
//  SpotifyMenuBarWidget
//
//  Created by David Mountain on 23/03/2015.
//  Copyright (c) 2015 David Mountain. All rights reserved.
//

import Cocoa

enum SupportedPrograms: Int {
    case Spotify
    case Rdio
    
    func toString() -> String {
        switch self {
        case Spotify:
            return "Spotify"
        case Rdio:
            return "Rdio"
        }
    }
}

struct SettingKeys {
    static let PreferredSource = "PreferredSource"
    static let PreferredFontFamily = "PreferredFontFamily"
    static let PreferredFontSize = "PreferredFontSize"
}

class DMSettingsHelper: NSObject {
    
    class func initializeIfNeeded() {
        if get(SettingKeys.PreferredSource) == nil {
            set(SettingKeys.PreferredSource, value: 0)
        }
        
        if get(SettingKeys.PreferredFontFamily) == nil {
            set(SettingKeys.PreferredFontFamily, value: "Avenir")
        }
        
        if get(SettingKeys.PreferredFontSize) == nil {
            set(SettingKeys.PreferredFontSize, value: 10)
        }
    }
    
    class func defaults() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
    
    class func set(key:String, value:AnyObject) {
        defaults().setObject(value, forKey: key)
        defaults().synchronize()
    }
    
    class func get(key:String) -> AnyObject? {
        return defaults().objectForKey(key)
    }
    
}
