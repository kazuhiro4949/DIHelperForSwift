//
//  StubViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/21.
//  
//

import Cocoa
import SwiftSyntax
import Sourceful

class StubViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var valTextField: NSTextField!
    
    @IBOutlet weak var sampleSourceTextView: SyntaxTextView!
    @IBOutlet weak var convertedSourceTextView: SyntaxTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        
        super.viewDidLoad()
        setupTextView()
        sampleSourceTextView.text = SampleParsedSource.protocolSample
        updateConvertedText(sampleSourceTextView.text)
        
        nameTextField.stringValue = Settings
            .shared
            .stubSettings
            .nameFormat ?? ""
        valTextField.stringValue = Settings
            .shared
            .stubSettings
            .returnValueFormat ?? ""
    }
    
    private func setupTextView() {
        sampleSourceTextView.delegate = self
        sampleSourceTextView.theme = DefaultSourceCodeTheme()
        
        convertedSourceTextView.delegate = self
        convertedSourceTextView.contentTextView.isEditable = false
        convertedSourceTextView.theme = DefaultSourceCodeTheme()
    }
    
    private func updateConvertedText(_ text: String) {
        do {
            
            let sourceFile = try SyntaxParser.parse(
                source: text
            )
            
            let generater = MockGenerater(mockType: .stub)
            generater.walk(sourceFile)
            
            convertedSourceTextView.text = generater
                .mockClasses
                .first?
                .classDeclSyntax
                .description ?? ""
        } catch _ {}

    }
    
    @IBAction func textFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.nameFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func returnValueTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.returnValueFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
}

extension StubViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        updateConvertedText(sampleSourceTextView.text)
    }
}

extension StubViewController: SyntaxTextViewDelegate {
    func lexerForSource(_ source: String) -> Lexer {
        SwiftLexer()
    }
    
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        if syntaxTextView == sampleSourceTextView {
           updateConvertedText(sampleSourceTextView.text)
        }
    }
}
