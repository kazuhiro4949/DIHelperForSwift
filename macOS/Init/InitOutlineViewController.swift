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

extension InitOutlineViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("InitTableViewCell"), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = dataSource[row].name
        return cell
    }
    
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        
    }
}

