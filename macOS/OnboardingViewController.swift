//
//  OnboardingViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/22.
//  
//

import Cocoa

protocol OnboardingViewControllerDelegate: AnyObject {
    func onboardingViewControllerCloseButtonDidTap(_ vc: OnboardingViewController)
}

class OnboardingViewController: NSViewController {
    weak var delegate: OnboardingViewControllerDelegate?
    
    var startVc: OnboardingStartViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? OnboardingStartViewController {
            startVc = vc
            startVc.delegate = self
        }
    }
}

extension OnboardingViewController: OnboardingStartViewControllerDelegate {
    func onboardingStartViewControllerDidTapCloseButton(_ vc: OnboardingStartViewController) {
        delegate?.onboardingViewControllerCloseButtonDidTap(self)
    }
}
