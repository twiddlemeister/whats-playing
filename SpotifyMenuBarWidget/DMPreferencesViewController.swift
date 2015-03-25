//
//  DMPreferencesViewController.swift
//  SpotifyMenuBarWidget
//
//  Created by David Mountain on 23/03/2015.
//  Copyright (c) 2015 David Mountain. All rights reserved.
//

import Cocoa

protocol DMPreferencesViewControllerDelegate {
    func shouldClosePreferencesWindow(reload: Bool)
}

class DMPreferencesViewController: NSViewController {
    
    var delegate: DMPreferencesViewControllerDelegate?
    
    @IBOutlet var fontPicker: NSComboBox!
    @IBOutlet var fontSizeField: NSTextField!
    @IBOutlet var fontSizeStepper: NSStepper!
    @IBOutlet var cancelButton: NSButton!
    @IBOutlet var okButton: NSButton!
    var stepperValue: Int = 0
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        stepperValue = DMSettingsHelper.get(SettingKeys.PreferredFontSize) as Int
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontSizeField.focusRingType = NSFocusRingType.None
        fontPicker.focusRingType = NSFocusRingType.None
        
        populateFontPicker()
    }
    
    private func populateFontPicker() {
        var availableFamilies = NSFontManager.sharedFontManager().availableFontFamilies
        var preferredFont = DMSettingsHelper.get(SettingKeys.PreferredFontFamily) as String
        
        for family:AnyObject in availableFamilies {
            var familyString = family as String
            fontPicker.addItemWithObjectValue(familyString)
        }
        
        fontPicker.selectItemWithObjectValue(preferredFont)
    }
    
    @IBAction func okButtonTapped(sender: AnyObject) {
        DMSettingsHelper.set(SettingKeys.PreferredFontFamily, value: fontPicker.objectValueOfSelectedItem!)
        DMSettingsHelper.set(SettingKeys.PreferredFontSize, value: stepperValue)
        delegate?.shouldClosePreferencesWindow(true)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        delegate?.shouldClosePreferencesWindow(false)
    }
}
