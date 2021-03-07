//
//  InitSplitViewController.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/03/06.
//  
//

import Cocoa


class InitSplitViewController: NSSplitViewController {
    var initDetailViewController: InitDetailViewController {
        splitViewItems[1].viewController as! InitDetailViewController
    }
    var initOutlineViewController: InitOutlineViewController {
        splitViewItems[0].viewController as! InitOutlineViewController
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initOutlineViewController.delegate = self
    }
}

extension InitSplitViewController: InitOutlineViewControllerDelegate {
    func initOutlineViewController(_ vc: InitOutlineViewController, didSelect snippet: InitSnippet) {
        initDetailViewController.snippet = snippet
    }
}
