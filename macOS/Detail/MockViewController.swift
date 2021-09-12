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
import Converter

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
    @IBOutlet weak var kvcButton: NSButton!
    
    
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
            .mockSettings
            .wasCalledFormat ?? ""
        
        callCountTextField.stringValue = Settings
            .shared
            .mockSettings
            .callCountFormat ?? ""
        
        argsTextField.stringValue = Settings
            .shared
            .mockSettings
            .passedArgumentFormat ?? ""
        valTextField.stringValue = Settings
            .shared
            .mockSettings
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
        let linkAttrValue = NSAttributedString.makeLink(
            URL(string: "https://bit.ly/2WVj9ux")!
        )
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
                .mockSettings.getTarget(target: .property)
        )
        functionTargetButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .mockSettings.getTarget(target: .function)
        )
        initializerTargetButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .mockSettings.getTarget(target: .initilizer)
        )
        
        calledOrNotCaptureButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .mockSettings.getCapture(capture: .calledOrNot)
            )
        
        callCountCaptureButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .mockSettings.getCapture(capture: .callCount)
            )
        
        passedArgumentCaptureButton.state = NSControl.StateValue(
            isOn: !Settings
                .shared
                .mockSettings.getCapture(capture: .passedArgument)
            )
        kvcButton.state = NSControl.StateValue(
            isOn: !Settings.shared.mockSettings.getScene(scene: .kvc)
        )
    }
    
    func updateConvertedText(_ text: String) {
        do {
            
            let sourceFile = try SyntaxParser.parse(
                source: text
            )
            
            let generater = MockGenerater(mockType: .mock)
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
        Settings.shared.mockSettings.nameFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func wasCalledTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.mockSettings.wasCalledFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func callCountTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.mockSettings.callCountFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func passedArgumentTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.mockSettings.passedArgumentFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func returnValueTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.mockSettings.returnValueFormat = value
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func targetButtonDidClick(_ sender: NSButton) {
        guard let target = Settings.Target(rawValue: sender.tag) else {
            sender.state = sender.state.toggle()
            return
        }
        
        Settings.shared.mockSettings.setTarget(
            target: target,
            value: sender.state != .on
        )
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func kvcButtonDidClick(_ sender: NSButton) {
        Settings.shared.mockSettings.setScene(
            scene: .kvc,
            value: sender.state != .on
        )
        updateConvertedText(sampleSourceTextView.text)
    }
    
    @IBAction func captureButtonDidClick(_ sender: NSButton) {
        guard let capture = Settings.MockSetting.Capture(rawValue: sender.tag) else {
            sender.state = sender.state.toggle()
            return
        }
        
        Settings.shared.mockSettings.setCapture(
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

