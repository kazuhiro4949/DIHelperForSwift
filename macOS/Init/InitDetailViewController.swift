//
//  InitDetailViewController.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/03/07.
//  
//

import Cocoa
import Sourceful

class InitDetailViewController: NSViewController {
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var textView: SyntaxTextView!
    
    var snippet: InitSnippet? {
        didSet {
            bindData(snippet)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.theme = DefaultSourceCodeTheme()
    }
    
    func bindData(_ snippet: InitSnippet?) {
        titleTextField.stringValue
            = snippet?.name ?? ""
        textView.text
            = snippet?.body ?? ""
    }
    
}
