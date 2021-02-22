//
//  DetailViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/23.
//  
//

import Cocoa

class DetailViewController: NSViewController {
    var childViewController: NSViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func replace(to vc: NSViewController) {
        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = true
        vc.view.autoresizingMask = [.width, .height]
        vc.view.frame = view.bounds
        
        
        if let childVc = childViewController {
            view.animator().replaceSubview(childVc.view, with: vc.view)
        } else {
            view.addSubview(vc.view)
        }
        
        childViewController?.removeFromParent()
        childViewController = vc
    }
}
