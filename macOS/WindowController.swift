//
//  WindowController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/27.
//  
//

import Cocoa

class WindowController: NSWindowController {
    @IBOutlet weak var toolbar: NSToolbar!
    
    var initWindowController: InitWIndowController?
    
    private var observers = [NSObjectProtocol]()
    
    @IBAction func helpButtonDidTap(_ sender: NSButton) {
        let vc = storyboard?.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("OnboardingViewController")
        ) as! OnboardingViewController
        vc.delegate = self
        contentViewController?.presentAsSheet(vc)
    }
    
    @IBAction func addInitListDidClick(_ sender: NSToolbarItem) {
        if let initWindowController = initWindowController {
            initWindowController.window?.orderFrontRegardless()
            return
        }
        
        let windowController = storyboard?.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("InitWIndowController")
        ) as! InitWIndowController
        windowController.showWindow(windowController.window)
        windowController.window?.delegate = self
        self.initWindowController = windowController
    }
    

    override func windowDidLoad() {
        super.windowDidLoad()
    }
}

extension WindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        initWindowController = nil
    }
}

extension WindowController: OnboardingViewControllerDelegate {
    func onboardingViewControllerCloseButtonDidTap(_ vc: OnboardingViewController) {
        contentViewController?.dismiss(vc)
    }
}

extension WindowController: NSSharingServicePickerDelegate {

}
