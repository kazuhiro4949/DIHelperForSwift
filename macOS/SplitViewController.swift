//
//  SplitViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/23.
//  
//

import Cocoa

class SplitViewController: NSSplitViewController {
    var detailViewController: DetailViewController {
        splitViewItems[1].viewController as! DetailViewController
    }
    
    var menuViewController: MenuViewController {
        splitViewItems[0].viewController as! MenuViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuViewController.delegate = self
        let vc = storyboard?.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("ProtocolViewController")
        ) as! ProtocolViewController
        detailViewController.replace(to: vc)
        menuViewController.tableView.selectRowIndexes([0], byExtendingSelection: true)
    }
}

extension SplitViewController: MenuViewControllerDelegate {
    func menuViewController(_ vc: MenuViewController, didSelct menu: Menu) {
        switch menu {
        case .mock:
            let vc = storyboard?.instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier("MockViewController")
            ) as! MockViewController
            detailViewController.replace(to: vc)
        case .protocol:
            let vc = storyboard?.instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier("ProtocolViewController")
            ) as! ProtocolViewController
            detailViewController.replace(to: vc)
        }
    }
}
