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
    
    private var observers = [NSObjectProtocol]()
    
    @IBAction func helpButtonDidTap(_ sender: NSButton) {
        let vc = storyboard?.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("InitSplitViewController")
        ) as! InitSplitViewController
//        vc.delegate = self
        contentViewController?.presentAsSheet(vc)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }

}

extension WindowController: OnboardingViewControllerDelegate {
    func onboardingViewControllerCloseButtonDidTap(_ vc: OnboardingViewController) {
        contentViewController?.dismiss(vc)
    }
}

extension WindowController: NSSharingServicePickerDelegate {

}
