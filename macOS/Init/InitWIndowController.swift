//
//  InitWIndowController.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/03/07.
//  
//

import Cocoa

class InitWIndowController: NSWindowController {

    var splitViewController: InitSplitViewController {
        contentViewController as! InitSplitViewController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    @IBAction func addInitDidClick(_ sender: NSToolbarItem) {
        let snippet = InitSnippet(
            name: "NewClass",
            body: "NewClass()")
        
        var snippets = UserDefaults.group.snippets
        snippets.insert(snippet, at: 0)
        UserDefaults.group.snippets = snippets
        splitViewController.initOutlineViewController.create(snippet)
        splitViewController.initDetailViewController.create(snippet)
    }
}
