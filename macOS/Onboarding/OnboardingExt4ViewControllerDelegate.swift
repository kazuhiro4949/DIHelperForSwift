//
//  OnboardingExt4ViewControllerDelegate.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/24.
//  
//

import Cocoa

protocol OnboardingExt4ViewControllerDelegate: AnyObject {
    func onboardingExt4ViewControllerDelegateDidTapBackButton(_ vc: OnboardingExt4ViewController)
    func onboardingExt4ViewControllerDelegateDidTapNextButton(_ vc: OnboardingExt4ViewController)
}

class OnboardingExt4ViewController: NSViewController {
    weak var delegate: OnboardingExt4ViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func backButtonDidClick(_ sender: OnboardingButton) {
        delegate?.onboardingExt4ViewControllerDelegateDidTapBackButton(self)
    }
    
    
    @IBAction func nextButtonDidClick(_ sender: OnboardingButton) {
        delegate?.onboardingExt4ViewControllerDelegateDidTapNextButton(self)
    }
}

