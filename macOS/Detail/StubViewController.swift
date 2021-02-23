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
    @IBOutlet weak var documentationTextField: NSTextField!
    
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
        
        setupLink()
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
        Settings.shared.spySettings.returnValueFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func helpButtonDidClick(_ sender: Any) {
        let vc = storyboard?.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("OnboardingViewController")
        ) as! OnboardingViewController
        vc.delegate = self
        self.presentAsSheet(vc)
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

extension StubViewController: OnboardingViewControllerDelegate {
    func onboardingViewControllerCloseButtonDidTap(_ vc: OnboardingViewController) {
        dismiss(vc)
    }
}
