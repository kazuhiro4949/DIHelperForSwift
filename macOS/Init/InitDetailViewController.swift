//
//  InitDetailViewController.swift
//  DI Helper for Swift
//
//  Created by Kazuhiro Hayashi on 2021/03/07.
//  
//

import Cocoa
import Sourceful

protocol InitDetailViewControllerDelegate: AnyObject {
    func initDetailViewController(_ vc: InitDetailViewController, didChange snippet: InitSnippet)
}

class InitDetailViewController: NSViewController {
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var textView: SyntaxTextView!
    
    weak var delegate: InitDetailViewControllerDelegate?
    
    var snippet: InitSnippet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        textView.theme = DefaultSourceCodeTheme()
    }
    
    func bindData(_ snippet: InitSnippet?) {
        titleTextField.stringValue
            = snippet?.name ?? ""
        textView.text
            = snippet?.body ?? ""
    }
    
    func create(_ snippet: InitSnippet) {
        self.snippet = snippet
        bindData(snippet)
    }
}

extension InitDetailViewController: SyntaxTextViewDelegate {
    func lexerForSource(_ source: String) -> Lexer {
        SwiftLexer()
    }
    
    
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        snippet?.body = syntaxTextView.text
        if let snippet = snippet {
            delegate?.initDetailViewController(self, didChange: snippet)
        }
    }
}
