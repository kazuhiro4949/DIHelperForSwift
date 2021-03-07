//
//  InitWIndowController.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/03/07.
//  
//

import Cocoa

class InitWIndowController: NSWindowController, NSToolbarItemValidation {
    @IBOutlet weak var removeToolbarItem: NSToolbarItem!
    
    var splitViewController: InitSplitViewController {
        contentViewController as! InitSplitViewController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        
        updateRemoveButton()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    @IBAction func addInitDidClick(_ sender: NSToolbarItem) {
        splitViewController.addItem()
        updateRemoveButton()
    }
    
    @IBAction func removeInitDidClick(_ sender: NSToolbarItem) {
        splitViewController.removeSelectedItem()
        updateRemoveButton()
    }
    
    func updateRemoveButton() {
        removeToolbarItem.isEnabled = (0 < splitViewController.snippets.count )
    }
    
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        item.isEnabled
    }
}
