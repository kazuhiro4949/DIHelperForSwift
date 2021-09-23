//
//  AppDelegate.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/10.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    static let appAppearanceChanged = NSNotification.Name("appAppearanceChanged")
    
    private var effectiveAppearanceObserver: NSObjectProtocol?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        effectiveAppearanceObserver = NSApp.observe(\.effectiveAppearance, options: [.new, .old]) { app, change in
            var dict = [AnyHashable : Any]()
            dict["effectiveAppearance"] = change.newValue
            NotificationCenter.default.post(name: AppDelegate.appAppearanceChanged, object: app, userInfo: dict)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    @IBAction func showHelp(_ sender: NSMenuItem) {
        if let delegate = NSApplication.shared.keyWindow?.contentViewController as? (NSViewController & OnboardingViewControllerDelegate) {
            let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier("OnboardingViewController")
            ) as! OnboardingViewController

            vc.delegate = delegate
            delegate.presentAsSheet(vc)
        }
    }
}

