//
//  MockViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/23.
//  
//

import Cocoa
import SwiftSyntax

class MockViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    
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
    
    @IBOutlet weak var sampleSourceTextView: NSTextView!
    @IBOutlet weak var convertedSourceTextView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        sampleSourceTextView.string = SampleParsedSource.protocolSample
        updateConvertedText(sampleSourceTextView.string)
        
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
    }
    
    private func setupTextView() {
        sampleSourceTextView.textContainerInset = CGSize(
            width: 8,
            height: 8
        )
        convertedSourceTextView.textContainerInset = CGSize(
            width: 8,
            height: 8
        )
        
        sampleSourceTextView.typingAttributes = [
            .font: NSFont(name: "Monaco", size: 16)!,
            .foregroundColor: NSColor.textColor
        ]
        convertedSourceTextView.typingAttributes = [
            .font: NSFont(name: "Monaco", size: 16)!,
            .foregroundColor: NSColor.textColor
        ]
        
        sampleSourceTextView.maxSize = NSSize(width: .max, height: .max)
        sampleSourceTextView.isHorizontallyResizable = true
        sampleSourceTextView.textContainer?.widthTracksTextView = false
        sampleSourceTextView.textContainer?.containerSize = NSSize(width: .max, height: .max)
        
        convertedSourceTextView.maxSize = NSSize(width: .max, height: .max)
        convertedSourceTextView.isHorizontallyResizable = true
        convertedSourceTextView.textContainer?.widthTracksTextView = false
        convertedSourceTextView.textContainer?.containerSize = NSSize(width: .max, height: .max)
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
            
            convertedSourceTextView.string = generater
                .mockClasses
                .first?
                .classDeclSyntax
                .description ?? ""
        } catch _ {}

    }
    
    
    @IBAction func textFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.nameFormat = value
        updateConvertedText(sampleSourceTextView.string)
    }
    
    @IBAction func wasCalledTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.wasCalledFormat = value
        updateConvertedText(sampleSourceTextView.string)
    }
    
    @IBAction func callCountTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.callCountFormat = value
        updateConvertedText(sampleSourceTextView.string)
    }
    
    @IBAction func passedArgumentTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.passedArgumentFormat = value
        updateConvertedText(sampleSourceTextView.string)
    }
    
    @IBAction func returnValueTextFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.returnValueFormat = value
        updateConvertedText(sampleSourceTextView.string)
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
        updateConvertedText(sampleSourceTextView.string)
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
        updateConvertedText(sampleSourceTextView.string)
    }
    
}


extension MockViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        updateConvertedText(sampleSourceTextView.string)
    }
}
