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

protocol InitOutlineViewControllerDelegate: AnyObject {
    func initOutlineViewController(_ vc: InitOutlineViewController, didSelect snippet: InitSnippet)
}

class InitOutlineViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    
    weak var delegate: InitOutlineViewControllerDelegate?
    
    var dataSource = Array(repeating: InitSnippet(name: "SomeClass", body: "SameClas()"), count: 100)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func didClickCell(_ sender: NSTableView) {
        let snippet = dataSource[sender.selectedRow]
        delegate?.initOutlineViewController(self, didSelect: snippet)
    }
}

extension InitOutlineViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        dataSource[row]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("InitTableViewCell"), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = dataSource[row].name
        return cell
    }
}

