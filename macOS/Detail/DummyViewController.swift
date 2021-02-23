//
//  DummyViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/14.
//  
//

import Cocoa
import SwiftSyntax
import Sourceful

class DummyViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var sampleSourceTextView: SyntaxTextView!
    @IBOutlet weak var convertedSourceTextView: SyntaxTextView!
    @IBOutlet weak var documentationTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        sampleSourceTextView.text = SampleParsedSource.protocolSample
        updateConvertedText(sampleSourceTextView.text)
        
        
        nameTextField.stringValue = Settings
            .shared
            .dummySettings
            .nameFormat ?? ""
        setupLink()
    }
    
    private func setupLink() {
        let linkAttrValue = NSAttributedString(
            string: "https://bit.ly/3dukEWt",
            attributes: [
                .link: URL(string: "https://bit.ly/3dukEWt")!,
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
            
            let generater = MockGenerater(mockType: .dummy)
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
        Settings.shared.dummySettings.nameFormat = value
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

extension DummyViewController: SyntaxTextViewDelegate {
    func lexerForSource(_ source: String) -> Lexer {
        SwiftLexer()
    }
    
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        if syntaxTextView == sampleSourceTextView {
           updateConvertedText(sampleSourceTextView.text)
        }
    }
}

extension DummyViewController: OnboardingViewControllerDelegate {
    func onboardingViewControllerCloseButtonDidTap(_ vc: OnboardingViewController) {
        dismiss(vc)
    }
}
