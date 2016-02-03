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
    private var timer: NSTimer?
    
    private var statusItem:NSStatusItem
    
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
        
        let tag = DMSettingsHelper.get(SettingKeys.PreferredSource) as! Int
        selectedSource = SupportedPrograms(rawValue: tag)
        
        statusItem.target = self
        statusItem.highlightMode = true;
        statusItem.menu = createMenu()
        statusItem.button?.toolTip = "What's Playing by @twiddlemeister"
        
        let frame = NSRect(x: 0, y: 0, width: 500, height: 350)
        let windowMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
        let rect = NSWindow.contentRectForFrameRect(frame, styleMask: windowMask)
        
        preferencesViewController = DMPreferencesViewController(nibName: "DMPreferencesViewController", bundle: NSBundle.mainBundle())
        preferencesViewController!.delegate = self
        
        prefsWindow = NSWindow(contentRect: rect, styleMask: windowMask, backing: NSBackingStoreType.Buffered, `defer`: false)
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
        let menu = NSMenu(title: "What's Playing Menu")
        
        menu.addItemWithTitle("Sources", action: nil, keyEquivalent: "")
        
        let spotifyItem = NSMenuItem(title: "Spotify", action: Selector("sourceMenuItemClicked:"), keyEquivalent: "")
        spotifyItem.target = self
        spotifyItem.tag = SupportedPrograms.Spotify.rawValue
        menu.addItem(spotifyItem)
        
        let iTunesItem = NSMenuItem(title: "iTunes", action: Selector("sourceMenuItemClicked:"), keyEquivalent: "")
        iTunesItem.target = self
        iTunesItem.tag = SupportedPrograms.iTunes.rawValue
        menu.addItem(iTunesItem)
        
        menu.addItem(NSMenuItem.separatorItem())
        
        let prefsItem = NSMenuItem(title: "Configure...", action: Selector("prefsMenuItemClicked"), keyEquivalent: "")
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
    
    func getImageForSelectedSource() -> NSImage? {
        var image:NSImage?
        
        if selectedSource == SupportedPrograms.Spotify {
            image = NSImage(named: "Spotify")
            image!.size = NSSize(width: 22, height: 16)
        } else if selectedSource == SupportedPrograms.iTunes {
            image = NSImage(named: "iTunes")
            image!.size = NSSize(width: 22, height: 22)
        } else {
            image = nil
        }
        
        return image
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
        
        let appleScript = NSAppleScript(source: scriptBody)
        descriptor = appleScript?.executeAndReturnError(&errorDictionary)
        
        var resultString:String?
        if descriptor != nil {
            resultString = descriptor!.stringValue
            if resultString != "" && resultString != nil {
                let parts = resultString!.componentsSeparatedByString("~")
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
        
        let fontFamily = DMSettingsHelper.get(SettingKeys.PreferredFontFamily) as! String
        let fontSize = DMSettingsHelper.get(SettingKeys.PreferredFontSize) as! Int
        let font = NSFont(name: fontFamily, size: CGFloat(fontSize))!
        
        let trackInfoString = trackString + " • " + artistString
        let attributes = [NSFontAttributeName: font]
        let attributedString = NSAttributedString(string: trackInfoString, attributes: attributes)
        
        statusItem.button?.image = getImageForSelectedSource()
        statusItem.button?.imagePosition = NSCellImagePosition.ImageLeft
        statusItem.button?.attributedTitle = attributedString
    }
    
    /**
     * NSUserInterfaceValidations
     */
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        let tag = menuItem.tag
        
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
