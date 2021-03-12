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
    @IBOutlet weak var emptyView: NSView!
    @IBOutlet weak var textView: SyntaxTextView!
    
    weak var delegate: InitDetailViewControllerDelegate?
    
    var snippet: InitSnippet?
    var isBinding = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        textView.theme = DefaultSourceCodeTheme()
        emptyView.isHidden = true
        textView.isHidden = false
    }
    
    func bindData(_ snippet: InitSnippet?) {
        isBinding = true
        
        
        textView.text
            = snippet?.body ?? ""
        isBinding = false
    }
    
    func create(_ snippet: InitSnippet) {
        self.snippet = snippet
        bindData(snippet)
        emptyView.isHidden = true
        textView.isHidden = false
    }
    
    func reset() {
        self.snippet = nil
        bindData(nil)
        emptyView.isHidden = false
        textView.isHidden = true
    }
}

extension InitDetailViewController: SyntaxTextViewDelegate {
    func lexerForSource(_ source: String) -> Lexer {
        SwiftLexer()
    }
    
    
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        snippet?.body = syntaxTextView.text
        if let snippet = snippet, !isBinding {
            delegate?.initDetailViewController(self, didChange: snippet)
        }
    }
}
