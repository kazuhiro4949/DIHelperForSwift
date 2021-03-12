//
//  MockViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/23.
//  
//

import Cocoa
import SwiftSyntax
import Sourceful

class MockViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var shareToolbarButton: NSButton!
    
    @IBOutlet weak var wasCalledTextField: NSTextField!
    @IBOutlet weak var callCountTextField: NSTextField!
    @IBOutlet weak var argsTextField: NSTextField!
    @IBOutlet weak var valTextField: NSTextField!
    
    @IBOutlet weak var propertyTargetButton: NSButton!
    @IBOutlet weak var functionTargetButton: NSButton!
    @IBOutlet weak var initializerTargetButton: NSButton!
    
    @IBOutlet weak var calledOrNotCaptureButton: NSButton!
    @IBOutlet weak var callCountCaptureButton: NSButton!
    @IBOutlet weak var passedArgumentCaptureButton: NSButton!
    
    @IBOutlet weak var sampleSourceTextView: SyntaxTextView!
    @IBOutlet weak var convertedSourceTextView: SyntaxTextView!
    @IBOutlet weak var documentationTextField: NSTextField!
    @IBOutlet weak var copyButton: NSButton!
    
    var observers = [NSObjectProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareToolbarButton.bezelStyle = .recessed
        shareToolbarButton.showsBorderOnlyWhileMouseInside = true
        
        copyButton.bezelStyle = .recessed
        copyButton.showsBorderOnlyWhileMouseInside = true
        
        setupTextView()
        sampleSourceTextView.text = SampleParsedSource.protocolSample
        updateConvertedText(sampleSourceTextView.text)
        
        wasCalledTextField.stringValue = Settings
            .shared
            .spySettings
            .wasCalledFormat ?? ""
        
        callCountTextField.stringValue = Settings
            .shared
            .spySettings
            .callCountFormat ?? ""
        
        argsTextField.stringValue = Settings
            .shared
            .spySettings
            .passedArgumentFormat ?? ""
        valTextField.stringValue = Settings
            .shared
            .spySettings
            .returnValueFormat ?? ""
        
        setupButtons()
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
            string: "https://bit.ly/3buxrp4",
            attributes: [
                .link: URL(string: "https://bit.ly/3buxrp4")!,
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
    
    private func setupButtons() {
        propertyTargetButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .spySettings.getTarget(target: .property)
        )
        functionTargetButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .spySettings.getTarget(target: .function)
        )
        initializerTargetButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .spySettings.getTarget(target: .initilizer)
        )
        
        calledOrNotCaptureButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .spySettings.getCapture(capture: .calledOrNot)
            )
        
        callCountCaptureButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .spySettings.getCapture(capture: .callCount)
            )
        
        passedArgumentCaptureButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .spySettings.getCapture(capture: .passedArgument)
            )
    }
    
    func updateConvertedText(_ text: String) {
        do {
            
            let sourceFile = try SyntaxParser.parse(
                source: text
            )
            
            let generater = MockGenerater(mockType: .spy)
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
    
    @IBAction func wasCalledTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.wasCalledFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func callCountTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.callCountFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func passedArgumentTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.passedArgumentFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func returnValueTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.returnValueFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func targetButtonDidClick(_ sender: NSButton) {
        guard let target = Settings.Target(rawValue: sender.tag) else {
            sender.state = sender.state.toggle()
            return
        }
        
        Settings.shared.spySettings.setTarget(
            target: target,
            value: sender.state != .on
        )
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func captureButtonDidClick(_ sender: NSButton) {
        guard let capture = Settings.SpySetting.Capture(rawValue: sender.tag) else {
            sender.state = sender.state.toggle()
            return
        }
        
        Settings.shared.spySettings.setCapture(
            capture: capture,
            value: sender.state != .on
        )
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


extension MockViewController: SyntaxTextViewDelegate {
    func lexerForSource(_ source: String) -> Lexer {
        SwiftLexer()
    }
    
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        if syntaxTextView == sampleSourceTextView {
           updateConvertedText(sampleSourceTextView.text)
        }
    }
}

