//
//  DMAppController.swift
//  SpotifyMenuBarWidget
//
//  Created by David Mountain on 19/03/2015.
//  Copyright (c) 2015 David Mountain. All rights reserved.
//

import Cocoa

private let _instance:DMAppController = DMAppController();

class DMAppController: NSObject, NSUserInterfaceValidations, DMPreferencesViewControllerDelegate {
    
    private var trackString:String
    private var artistString:String
    private var selectedSource: SupportedPrograms!
    
    private var statusItem:NSStatusItem
    private var timer: NSTimer?
    
    private var preferencesViewController: DMPreferencesViewController?
    private var windowController: NSWindowController?
    private var prefsWindow: NSWindow?
    
    class func instance() -> DMAppController {
        return _instance
    }
    
    override init() {
        trackString = ""
        artistString = ""
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        
        super.init()
        
        setup()
        getCurrentPlayingMetadata()
    }
    
    func setup() {
        DMSettingsHelper.initializeIfNeeded()
        
        rescheduleTimer()
        
        var tag = DMSettingsHelper.get(SettingKeys.PreferredSource) as Int
        selectedSource = SupportedPrograms(rawValue: tag)
        
        statusItem.target = self
        statusItem.toolTip = "What's Playing by @twiddlemeister"
        statusItem.menu = createMenu()
        
        var frame = NSRect(x: 0, y: 0, width: 500, height: 350)
        var windowMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
        var rect = NSWindow.contentRectForFrameRect(frame, styleMask: windowMask)
        
        preferencesViewController = DMPreferencesViewController(nibName: "DMPreferencesViewController", bundle: NSBundle.mainBundle())
        preferencesViewController!.delegate = self
        
        prefsWindow = NSWindow(contentRect: rect, styleMask: windowMask, backing: NSBackingStoreType.Buffered, defer: false)
        prefsWindow!.title = "What's Playing Preferences"
        prefsWindow!.center()
        prefsWindow!.contentViewController = preferencesViewController
        
        windowController = NSWindowController(window: prefsWindow)
    }
    
    func rescheduleTimer() {
        timer?.invalidate()
        timer = nil
        timer = NSTimer.scheduledTimerWithTimeInterval(
            5,
            target: self,
            selector: Selector("getCurrentPlayingMetadata"),
            userInfo: nil,
            repeats: true)
    }
    
    func createMenu() -> NSMenu {
        var menu = NSMenu(title: "What's Playing Menu")
        
        menu.addItemWithTitle("Sources", action: nil, keyEquivalent: "")
        
        var spotifyItem = NSMenuItem(title: "Spotify", action: Selector("sourceMenuItemClicked:"), keyEquivalent: "")
        spotifyItem.target = self
        spotifyItem.tag = SupportedPrograms.Spotify.rawValue
        menu.addItem(spotifyItem)
        
        var rdioItem = NSMenuItem(title: "Rdio", action: Selector("sourceMenuItemClicked:"), keyEquivalent: "")
        rdioItem.target = self
        rdioItem.tag = SupportedPrograms.Rdio.rawValue
        menu.addItem(rdioItem)
        
        menu.addItem(NSMenuItem.separatorItem())
        
        var prefsItem = NSMenuItem(title: "Configure...", action: Selector("prefsMenuItemClicked"), keyEquivalent: "")
        prefsItem.target = self
        prefsItem.tag = 1004
        menu.addItem(prefsItem)
        
        menu.addItem(NSMenuItem.separatorItem())
        
        menu.addItemWithTitle("What's Playing by @twiddlemeister", action: nil, keyEquivalent: "")
        
        return menu
    }
    
    func sourceMenuItemClicked(menuItem: NSMenuItem) {
        DMSettingsHelper.set(SettingKeys.PreferredSource, value: menuItem.tag)
        selectedSource = SupportedPrograms(rawValue: menuItem.tag)
    }
    
    func prefsMenuItemClicked() {
        windowController?.showWindow(self)
    }
    
    func getCurrentPlayingMetadata() {
        var descriptor:NSAppleEventDescriptor? = nil
        
        var scriptBody = "if application \"\(selectedSource.toString())\" is running then"
        scriptBody += "\ntell application \"\(selectedSource.toString())\""
        scriptBody += "\nset s_trackObj to current track"
        scriptBody += "\nset s_trackName to name of s_trackObj"
        scriptBody += "\nset s_artistName to artist of s_trackObj"
        scriptBody += "\nend tell"
        scriptBody += "\nreturn s_trackName & \"~\" & s_artistName"
        scriptBody += "\nend if"
        
        var errorDictionary:NSDictionary?
        
        var appleScript = NSAppleScript(source: scriptBody)
        descriptor = appleScript?.executeAndReturnError(&errorDictionary)
        
        var resultString:String
        if descriptor != nil {
            resultString = NSString(data: descriptor!.data, encoding: NSUTF8StringEncoding)!
            if resultString != "" {
                let parts = resultString.componentsSeparatedByString("~")
                trackString = parts[0]
                artistString = parts[1]
            } else {
                trackString = "No track"
                artistString = "No artist"
            }
        } else {
            trackString = "No track"
            artistString = "No artist"
        }
        
        var fontFamily = DMSettingsHelper.get(SettingKeys.PreferredFontFamily) as String
        var fontSize = DMSettingsHelper.get(SettingKeys.PreferredFontSize) as Int
        
        var attributes = [NSFontAttributeName: NSFont(name: fontFamily, size: CGFloat(fontSize))!]
        var attributedString = NSAttributedString(string: trackString + " • " + artistString, attributes: attributes)
        statusItem.attributedTitle = attributedString
    }
    
    /**
     * NSUserInterfaceValidations
     */
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        var tag = menuItem.tag
        
        if tag == selectedSource.rawValue {
            menuItem.state = NSOnState
        } else {
            menuItem.state = NSOffState
        }
        
        return true
    }
    
    func validateUserInterfaceItem(anItem: NSValidatedUserInterfaceItem) -> Bool {
        return true
    }
    
    /**
     * DMPreferencesViewControllerDelegate
     */
    func shouldClosePreferencesWindow(reload: Bool) {
        if reload {
            getCurrentPlayingMetadata()
            rescheduleTimer()
        }
        
        windowController!.close()
    }

}
