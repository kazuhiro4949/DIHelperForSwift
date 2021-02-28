//
//  AppDelegate.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/10.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
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

