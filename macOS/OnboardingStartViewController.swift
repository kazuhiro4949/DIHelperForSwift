//
//  OnboardingStartViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/22.
//  
//

import Cocoa

protocol OnboardingStartViewControllerDelegate: AnyObject {
    func onboardingStartViewControllerDidTapCloseButton(_ vc: OnboardingStartViewController)
}

class OnboardingStartViewController: NSViewController {
    
    weak var delegate: OnboardingStartViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func closeButtonDidClick(_ sender: OnboardingButton) {
        delegate?.onboardingStartViewControllerDidTapCloseButton(self)
    }
    
    
    @IBAction func nextButtonDidClick(_ sender: OnboardingButton) {
    }
}
