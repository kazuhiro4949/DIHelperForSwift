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
        if item is InitSnippet {
            return 0
        } else {
            return dataSource.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        dataSource[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        false
    }
    
    
}
