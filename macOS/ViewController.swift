//
//  ViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/10.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if !UserDefaults.standard.isAlreadyLaunched {
            let vc = storyboard?.instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier("OnboardingViewController")
            ) as! OnboardingViewController
            vc.delegate = self
            self.presentAsSheet(vc)
        }

        UserDefaults.standard.isAlreadyLaunched = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension UserDefaults {
    var isAlreadyLaunched: Bool {
        set {
            set(newValue, forKey: "isAlreadyLaunched")
        }
        get {
            bool(forKey: "isAlreadyLaunched")
        }
    }
}

extension ViewController: OnboardingViewControllerDelegate {
    func onboardingViewControllerCloseButtonDidTap(_ vc: OnboardingViewController) {
        dismiss(vc)
    }
}
