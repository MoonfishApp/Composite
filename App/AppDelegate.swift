//
//  AppDelegate.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/1/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private lazy var preferencesWindowController = NSWindowController.instantiate(storyboard: "Preferences")

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if UserDefaults.standard.bool(forKey: UserDefaultStrings.doNotShowDependencyWizard.rawValue) == false {
            showInstallWizard()
        } else {
            (DocumentController.shared as! DocumentController).newProject(self)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
//    @IBAction func showPreferences(_ sender: Any) {
//        
//        if preferencesController == nil {
//            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)
//            preferencesController = storyboard.instantiateInitialController() as? PreferencesWindowController
//        }
//        
//        if let preferencesController = preferencesController {
//            preferencesController.showWindow(sender)
//        }
//    }
    
    func showInstallWizard() {
        let installToolchainStoryboard = NSStoryboard(name: NSStoryboard.Name("InstallToolchain"), bundle: nil)
        let installWizard = installToolchainStoryboard.instantiateInitialController() as? NSWindowController
        installWizard?.showWindow(self)
    }
    
    override init() {
        
        // register default setting values
        let defaults = DefaultSettings.defaults.mapKeys { $0.rawValue }
        UserDefaults.standard.register(defaults: defaults)
        NSUserDefaultsController.shared.initialValues = defaults
        
        // instantiate DocumentController
        _ = DocumentController.shared
        
        // wake text finder up
        _ = TextFinder.shared
        
        // register transformers
        ValueTransformer.setValueTransformer(HexColorTransformer(), forName: HexColorTransformer.name)
        
        super.init()
    }
    
    // Prevent showing empty untitled project window at startup
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    /// show preferences window
    @IBAction func showPreferences(_ sender: Any?) {
        
        self.preferencesWindowController.showWindow(sender)
    }
    
}

// CotEditor extension
extension AppDelegate {
    
    /// open a specific page in Help contents
    @IBAction func openHelpAnchor(_ sender: AnyObject) {

        guard let identifier = (sender as? NSUserInterfaceItemIdentification)?.identifier else { return assertionFailure() }

        NSHelpManager.shared.openHelpAnchor(identifier.rawValue, inBook: Bundle.main.helpBookName)
    }

    
    
}
