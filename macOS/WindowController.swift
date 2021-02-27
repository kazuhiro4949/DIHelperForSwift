//
//  WindowController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/27.
//  
//

import Cocoa

class WindowPickerView: NSView {}

class WindowController: NSWindowController {
    @IBOutlet weak var toolbar: NSToolbar!
   
    @IBOutlet weak var shareToolbarButton: NSButton!
    
    
    @IBAction func helpButtonDidTap(_ sender: NSButton) {
        let vc = storyboard?.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("OnboardingViewController")
        ) as! OnboardingViewController
        vc.delegate = self
        contentViewController?.presentAsSheet(vc)
    }
    
    @IBAction func shareButtonDidTap(_ sender: NSButton) {
        let picker = NSSharingServicePicker(items: [NSURL(string: "https://saa.com")])
        picker.show(relativeTo: shareToolbarButton.bounds, of: shareToolbarButton, preferredEdge: .minY)
    }
    override func windowDidLoad() {
        super.windowDidLoad()

        shareToolbarButton.bezelStyle = .recessed
        shareToolbarButton.showsBorderOnlyWhileMouseInside = true
    }

}

extension WindowController: OnboardingViewControllerDelegate {
    func onboardingViewControllerCloseButtonDidTap(_ vc: OnboardingViewController) {
        contentViewController?.dismiss(vc)
    }
}

