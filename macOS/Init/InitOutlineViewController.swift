//
//  InitOutlineViewController.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/03/06.
//  
//

import Cocoa

struct InitSnippet: Codable {
    var name: String
    var body: String
}

protocol InitOutlineViewControllerDelegate: AnyObject {
    func initOutlineViewController(_ vc: InitOutlineViewController, didSelect snippet: InitSnippet)
    func initOutlineViewController(_ vc: InitOutlineViewController, didChange snippet: InitSnippet)
}

class InitOutlineViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    
    weak var delegate: InitOutlineViewControllerDelegate?
    
    var dataSource = [InitSnippet]()
    
    var currentIndex: Int {
        tableView.selectedRow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerForDraggedTypes([.string])        
    }

    @IBAction func didClickCell(_ sender: NSTableView) {
        let snippet = dataSource[sender.selectedRow]
        delegate?.initOutlineViewController(self, didSelect: snippet)
    }
    
    func create(_ snippet: InitSnippet) {
        dataSource.insert(snippet, at: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [0], withAnimation: .slideDown)
        tableView.endUpdates()
        tableView.selectRowIndexes([0], byExtendingSelection: false)
        
        let view = tableView.view(atColumn: 0, row: 0, makeIfNecessary: true) as? NSTableCellView
        view?.textField?.becomeFirstResponder()
    }
    
    func removeSelectedItem() {
        let selectedRow = tableView.selectedRow
        dataSource.remove(at: tableView.selectedRow)
        
        tableView.deselectRow(selectedRow)
        
        tableView.beginUpdates()
        tableView.removeRows(at: [selectedRow], withAnimation: .slideUp)
        tableView.endUpdates()
        
        if dataSource.count == 0 {
            // nothing to do
        } else if selectedRow == 0 {
           tableView.selectRowIndexes([0], byExtendingSelection: false)
        } else {
            tableView.selectRowIndexes([selectedRow], byExtendingSelection: false)
        }
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
        cell?.textField?.isEditable = true
        cell?.textField?.delegate = self
        cell?.textField?.stringValue = dataSource[row].name
        return cell
    }
}

extension InitOutlineViewController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField,
           let view = textField.superview as? NSTableCellView {
            
            
            let row = tableView.row(for: view)
            
            guard 0 <= row else {
                return
            }
            
            let name = textField.stringValue
            
            dataSource[row].name = name
            delegate?.initOutlineViewController(self, didChange: dataSource[row])
        }
    }
}

extension InitOutlineViewController {
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        } else {
            return []
        }
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let data = try? NSKeyedArchiver.archivedData(
            withRootObject: rowIndexes,
            requiringSecureCoding: false
        )
        pboard.declareTypes([.string], owner: self)
        pboard.setData(data, forType: .string)
        
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        let pboard = info.draggingPasteboard
        guard let data = pboard.data(forType: .string),
              let rowIndexes = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? IndexSet,
              let sourceRow = rowIndexes.first else {
            return false
        }
        
        var newRow = row
        if sourceRow < row {
            newRow = row - 1
            
        }
        
        let snippet = dataSource.remove(at: sourceRow)
        dataSource.insert(snippet, at: newRow)

        
        UserDefaults.group.snippets = dataSource
        
        tableView.beginUpdates()
        tableView.moveRow(at: sourceRow, to: newRow)
        tableView.endUpdates()
        
        return true
    }
}
