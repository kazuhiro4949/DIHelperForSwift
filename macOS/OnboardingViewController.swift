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
    var ext1Vc: OnboardingExt1ViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ext1Vc = storyboard?.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("OnboardingExt1ViewController")
        ) as? OnboardingExt1ViewController
        addChild(ext1Vc)
        ext1Vc.delegate = self
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
    
    func onboardingStartViewControllerDidTapNextButton(_ vc: OnboardingStartViewController) {
        transition(from: startVc, to: ext1Vc, options: .crossfade, completionHandler: nil)
    }
}

extension OnboardingViewController: OnboardingExt1ViewControllerDelegate {
    func onboardingExt1ViewControllerDelegateDidTapBackButton(_ vc: OnboardingExt1ViewController) {
        
    }
    
    func onboardingExt1ViewControllerDelegateDidTapNextButton(_ vc: OnboardingExt1ViewController) {
        
    }
}
