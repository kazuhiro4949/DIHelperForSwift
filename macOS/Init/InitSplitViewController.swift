//
//  InitSplitViewController.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/03/06.
//  
//

import Cocoa


class InitSplitViewController: NSSplitViewController {
    static let didUpdateNotification = NSNotification.Name("updateTypeAndInitializarList")
        
    var initDetailViewController: InitDetailViewController {
        splitViewItems[1].viewController as! InitDetailViewController
    }
    var initOutlineViewController: InitOutlineViewController {
        splitViewItems[0].viewController as! InitOutlineViewController
    }
    
    var snippets: [InitSnippet] {
        UserDefaults.group.snippets
    }
    
    func postUpdate() {
        NotificationCenter.default.post(name: InitSplitViewController.didUpdateNotification, object: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initOutlineViewController.delegate = self
        initDetailViewController.delegate = self
        
    
        let snnipets = UserDefaults.group.snippets
        if 0 < snnipets.count {
            initOutlineViewController.dataSource = snnipets
            initOutlineViewController.tableView.reloadData()
            initOutlineViewController.tableView.selectRowIndexes([0], byExtendingSelection: false)
            initDetailViewController.create(snnipets[0])
        } else {
            initDetailViewController.reset()
        }
    }
    
    func removeSelectedItem() {
        let selectedRow = initOutlineViewController.tableView.selectedRow
        guard 0 <= selectedRow else {
            return
        }
        var snippets = UserDefaults.group.snippets
        snippets.remove(at: selectedRow)
        UserDefaults.group.snippets = snippets
        
        initOutlineViewController.removeSelectedItem()
        
        let snippet: InitSnippet
        if 0 <= initOutlineViewController.tableView.selectedRow {
            snippet = snippets[initOutlineViewController.tableView.selectedRow]
            initDetailViewController.create(snippet)
        } else {
            initDetailViewController.reset()
        }
        postUpdate()
    }
    
    func addItem() {
        let snippet = InitSnippet(
            name: "UIViewController",
            body: "UIViewController(nibName: nil, bundle: nil)")
        
        var snippets = UserDefaults.group.snippets
        snippets.insert(snippet, at: 0)
        UserDefaults.group.snippets = snippets
        initOutlineViewController.create(snippet)
        initDetailViewController.create(snippet)
        postUpdate()
    }
}

extension InitSplitViewController: InitOutlineViewControllerDelegate {
    
    func initOutlineViewController(_ vc: InitOutlineViewController, didSelect snippet: InitSnippet) {
        initDetailViewController.create(snippet)
        postUpdate()
    }
    
    func initOutlineViewController(_ vc: InitOutlineViewController, didChange snippet: InitSnippet) {
    
        var snippets = UserDefaults.group.snippets
        snippets[vc.currentIndex] = snippet
        UserDefaults.group.snippets = snippets
        postUpdate()
    }
}


extension InitSplitViewController: InitDetailViewControllerDelegate {
    func initDetailViewController(_ vc: InitDetailViewController, didChange snippet: InitSnippet) {
        var snippets = UserDefaults.group.snippets
        snippets[initOutlineViewController.currentIndex] = snippet
        UserDefaults.group.snippets = snippets
        initOutlineViewController.dataSource = snippets
        postUpdate()
    }
}
