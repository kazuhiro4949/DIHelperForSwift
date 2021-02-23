//
//  OnboardingExt3ViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 3031/03/33.
//  
//

import Cocoa

protocol OnboardingExt3ViewControllerDelegate: AnyObject {
    func onboardingExt3ViewControllerDelegateDidTapBackButton(_ vc: OnboardingExt3ViewController)
    func onboardingExt3ViewControllerDelegateDidTapNextButton(_ vc: OnboardingExt3ViewController)
}

class OnboardingExt3ViewController: NSViewController {
    weak var delegate: OnboardingExt3ViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func backButtonDidClick(_ sender: OnboardingButton) {
        delegate?.onboardingExt3ViewControllerDelegateDidTapBackButton(self)
    }
    
    
    @IBAction func nextButtonDidClick(_ sender: OnboardingButton) {
        delegate?.onboardingExt3ViewControllerDelegateDidTapNextButton(self)
    }
}

