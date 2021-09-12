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
    var ext2Vc: OnboardingExt2ViewController!
    var ext3Vc: OnboardingExt3ViewController!
    var ext4Vc: OnboardingExt4ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVCs()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? OnboardingStartViewController {
            startVc = vc
            startVc.delegate = self
        }
    }
    
    private func setupVCs() {
        ext1Vc = storyboard?.instantiate(OnboardingExt1ViewController.self)
        addChild(ext1Vc)
        ext1Vc.delegate = self
        
        ext2Vc = storyboard?.instantiate(OnboardingExt2ViewController.self)
        addChild(ext2Vc)
        ext2Vc.delegate = self
        
        ext3Vc = storyboard?.instantiate(OnboardingExt3ViewController.self)
        addChild(ext3Vc)
        ext3Vc.delegate = self
        
        ext4Vc = storyboard?.instantiate(OnboardingExt4ViewController.self)
        addChild(ext4Vc)
        ext4Vc.delegate = self
    }
}

// MARK:- Start Deleagte
extension OnboardingViewController: OnboardingStartViewControllerDelegate {
    func onboardingStartViewControllerDidTapCloseButton(_ vc: OnboardingStartViewController) {
        delegate?.onboardingViewControllerCloseButtonDidTap(self)
    }
    
    func onboardingStartViewControllerDidTapNextButton(_ vc: OnboardingStartViewController) {
        transition(from: startVc, to: ext1Vc, options: .crossfade, completionHandler: nil)
    }
}

// MARK:- Page 1 Deleagte
extension OnboardingViewController: OnboardingExt1ViewControllerDelegate {
    func onboardingExt1ViewControllerDelegateDidTapBackButton(_ vc: OnboardingExt1ViewController) {
        transition(from: ext1Vc, to: startVc, options: .crossfade, completionHandler: nil)
        
    }
    
    func onboardingExt1ViewControllerDelegateDidTapNextButton(_ vc: OnboardingExt1ViewController) {
        transition(from: ext1Vc, to: ext2Vc, options: .crossfade, completionHandler: nil)
    }
}

// MARK:- Page 2 Deleagte
extension OnboardingViewController: OnboardingExt2ViewControllerDelegate {
    func onboardingExt2ViewControllerDelegateDidTapBackButton(_ vc: OnboardingExt2ViewController) {
        transition(from: ext2Vc, to: ext1Vc, options: .crossfade, completionHandler: nil)
        
    }
    
    func onboardingExt2ViewControllerDelegateDidTapNextButton(_ vc: OnboardingExt2ViewController) {
        transition(from: ext2Vc, to: ext3Vc, options: .crossfade, completionHandler: nil)
        
    }
}

// MARK:- Page 3 Deleagte
extension OnboardingViewController: OnboardingExt3ViewControllerDelegate {
    func onboardingExt3ViewControllerDelegateDidTapBackButton(_ vc: OnboardingExt3ViewController) {
        transition(from: ext3Vc, to: ext2Vc, options: .crossfade, completionHandler: nil)
        
    }
    
    func onboardingExt3ViewControllerDelegateDidTapNextButton(_ vc: OnboardingExt3ViewController) {
        transition(from: ext3Vc, to: ext4Vc, options: .crossfade, completionHandler: nil)
    }
}

// MARK:- Page 4 Deleagte
extension OnboardingViewController: OnboardingExt4ViewControllerDelegate {
    func onboardingExt4ViewControllerDelegateDidTapBackButton(_ vc: OnboardingExt4ViewController) {
        transition(from: ext4Vc, to: ext3Vc, options: .crossfade, completionHandler: nil)
    }
    
    func onboardingExt4ViewControllerDelegateDidTapNextButton(_ vc: OnboardingExt4ViewController) {
        delegate?.onboardingViewControllerCloseButtonDidTap(self)
    }
}
