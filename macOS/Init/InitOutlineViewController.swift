//
//  InitOutlineViewController.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/03/06.
//  
//

import Cocoa

struct InitSnippet {
    let name: String
    let body: String
}

class InitOutlineViewController: NSViewController {
    var dataSource = Array(repeating: InitSnippet(name: "SomeClass", body: "SameClas()"), count: 100)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension InitOutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return dataSource.count
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        dataSource[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        false
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let snippet = item as? InitSnippet {
            return snippet.name
        } else {
            return nil
        }
    }
    
    
}

extension InitOutlineViewController: NSOutlineViewDelegate {

    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let snippet = item as? InitSnippet {
            let tableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitTableColumn"), owner: self) as? NSTableCellView

            tableCellView?.textField?.stringValue = snippet.name
            return tableCellView
        } else {
            return nil
        }
    }
}
