//
//  OnboardingExt1ViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/22.
//  
//

import Cocoa

protocol OnboardingExt1ViewControllerDelegate: AnyObject {
    func onboardingExt1ViewControllerDelegateDidTapBackButton(_ vc: OnboardingExt1ViewController)
    func onboardingExt1ViewControllerDelegateDidTapNextButton(_ vc: OnboardingExt1ViewController)
}

class OnboardingExt1ViewController: NSViewController {
    weak var delegate: OnboardingExt1ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func backButtonDidClick(_ sender: OnboardingButton) {
        delegate?.onboardingExt1ViewControllerDelegateDidTapBackButton(self)
    }
    
    
    @IBAction func nextButtonDidClick(_ sender: OnboardingButton) {
        delegate?.onboardingExt1ViewControllerDelegateDidTapNextButton(self)
    }
}
