//
//  OnboardingExt2ViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/23.
//  
//

import Cocoa

protocol OnboardingExt2ViewControllerDelegate: AnyObject {
    func onboardingExt2ViewControllerDelegateDidTapBackButton(_ vc: OnboardingExt2ViewController)
    func onboardingExt2ViewControllerDelegateDidTapNextButton(_ vc: OnboardingExt2ViewController)
}

class OnboardingExt2ViewController: NSViewController {
    weak var delegate: OnboardingExt2ViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func backButtonDidClick(_ sender: OnboardingButton) {
        delegate?.onboardingExt2ViewControllerDelegateDidTapBackButton(self)
    }
    
    
    @IBAction func nextButtonDidClick(_ sender: OnboardingButton) {
        delegate?.onboardingExt2ViewControllerDelegateDidTapNextButton(self)
    }
}
