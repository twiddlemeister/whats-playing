//
//  AppDelegate.swift
//  SpotifyMenuBarWidget
//
//  Created by David Mountain on 19/03/2015.
//  Copyright (c) 2015 David Mountain. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem:NSStatusItem!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        DMAppController.instance()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

