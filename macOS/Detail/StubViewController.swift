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
import Converter

class StubViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var valTextField: NSTextField!
    @IBOutlet weak var shareToolbarButton: NSButton!
    @IBOutlet weak var copyButton: NSButton!

    @IBOutlet weak var sampleSourceTextView: SyntaxTextView!
    @IBOutlet weak var convertedSourceTextView: SyntaxTextView!
    @IBOutlet weak var documentationTextField: NSTextField!
    
    var observers = [NSObjectProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        
        shareToolbarButton.bezelStyle = .recessed
        shareToolbarButton.showsBorderOnlyWhileMouseInside = true
        
        copyButton.bezelStyle = .recessed
        copyButton.showsBorderOnlyWhileMouseInside = true
        
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
        
        setupLink()
        
        observers.append(NotificationCenter.default.addObserver(
            forName: InitSplitViewController.didUpdateNotification,
            object: nil,
            queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.updateConvertedText(self.sampleSourceTextView.text)
        })
    }
    
    private func setupLink() {
        let linkAttrValue = NSAttributedString(
            string: "https://bit.ly/37ybXq6",
            attributes: [
                .link: URL(string: "https://bit.ly/37ybXq6")!,
                .font: NSFont.systemFont(ofSize: 12)
                
        ])
        documentationTextField.attributedStringValue = linkAttrValue
        documentationTextField.isSelectable = true
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
        Settings.shared.stubSettings.nameFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func returnValueTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.mockSettings.returnValueFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func shareButtonDidTap(_ sender: NSButton) {
        let picker = NSSharingServicePicker(items: [convertedSourceTextView.text])
        picker.show(relativeTo: shareToolbarButton.bounds, of: shareToolbarButton, preferredEdge: .minY)
    }
    
    @IBAction func copyDidClick(_ sender: NSButton) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(
            convertedSourceTextView.text,
            forType: .string
        )
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
