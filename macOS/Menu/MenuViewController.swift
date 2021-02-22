//
//  MenuViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/23.
//  
//

import Cocoa

enum Menu: String {
    case `protocol`
    case mock
}

protocol MenuViewControllerDelegate: AnyObject {
    func menuViewController(_ vc: MenuViewController, didSelct menu: Menu)
}

class MenuViewController: NSViewController {
    private var dataSource: [Menu] = [.protocol, .mock]
    @IBOutlet weak var tableView: NSTableView!
    
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tableViewClicked(_ sender: NSTableView) {
        delegate?.menuViewController(self, didSelct: dataSource[sender.clickedRow])
    }
}

extension MenuViewController: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MenuTableCellView"), owner: self) as! MenuTableCellView
        cell.titleTextField?.stringValue = dataSource[row].rawValue.capitalized
        return cell
    }
}

extension MenuViewController: NSTableViewDelegate {
    
}
