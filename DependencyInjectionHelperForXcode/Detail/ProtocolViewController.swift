//
//  ProtocolViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/23.
//  
//

import Cocoa
import SwiftSyntax

class ProtocolViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    
    @IBOutlet weak var storedPropertyIgnoranceButton: NSButton!
    @IBOutlet weak var computedGetterSetterPropertyButton: NSButton!
    @IBOutlet weak var functionIgnoranceButton: NSButton!
    @IBOutlet weak var initializerIgnoranceButton: NSButton!
    @IBOutlet weak var internalMemberIgnoranceButton: NSButton!
    @IBOutlet weak var overrideMemberIgnoranceButton: NSButton!
    @IBOutlet weak var sampleSourceTextView: NSTextView!
    @IBOutlet weak var convertedSourceTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupTextView()
        sampleSourceTextView.string = SampleParsedSource.classSample
        updateConvertedText(sampleSourceTextView.string)
        
        nameTextField.stringValue = Settings
            .shared
            .protocolSettings
            .nameFormat ?? ""
        
        setupButtons()
    }
    
    private func setupTextView() {
        sampleSourceTextView.makePlaceText()
        sampleSourceTextView.textContainerInset = CGSize(
            width: 8,
            height: 8
        )
        convertedSourceTextView.textContainerInset = CGSize(
            width: 8,
            height: 8
        )
        
        sampleSourceTextView.typingAttributes = [
            .font: NSFont.userFixedPitchFont(ofSize: 16)!,
            .foregroundColor: NSColor.textColor
        ]
        convertedSourceTextView.typingAttributes = [
            .font: NSFont.userFixedPitchFont(ofSize: 16)!,
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
        storedPropertyIgnoranceButton.state = NSControl.StateValue(
            isOn: Settings
                .shared
                .protocolSettings
                .getIgnorance(ignorance: .storedProperty)
        )
        
        computedGetterSetterPropertyButton.state = NSControl.StateValue(
            isOn: Settings
                .shared
                .protocolSettings
                .getIgnorance(ignorance: .computedGetterSetterProperty)
        )
        
        functionIgnoranceButton.state = NSControl.StateValue(
            isOn: Settings
                .shared
                .protocolSettings
                .getIgnorance(ignorance: .function)
        )
        
        initializerIgnoranceButton.state = NSControl.StateValue(
            isOn: Settings
                .shared
                .protocolSettings
                .getIgnorance(ignorance: .initializer)
        )
        
        internalMemberIgnoranceButton.state = NSControl.StateValue(
            isOn: Settings
                .shared
                .protocolSettings
                .getIgnorance(ignorance: .internalMember)
        )
        
        
        overrideMemberIgnoranceButton.state = NSControl.StateValue(
            isOn: Settings
                .shared
                .protocolSettings
                .getIgnorance(ignorance: .override)
        )
    }
    
    func updateConvertedText(_ text: String) {
        do {
            
            let sourceFile = try SyntaxParser.parse(
                source: text
            )
            
            let extracter = ProtocolExtractor()
            extracter.walk(sourceFile)
            
            convertedSourceTextView.string = extracter.protocolDeclSyntaxList.first?.protocolDeclSyntax.description ?? ""
            
            
        } catch _ {}

    }
    
    
    @IBAction func textFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.protocolSettings.nameFormat = value
        updateConvertedText(sampleSourceTextView.string)
    }
    
    @IBAction func ignoranceButtonDidClick(_ sender: NSButton) {
        guard let ignorance = Settings.ProtocolSetting.Ignorance(rawValue: sender.tag) else {
            sender.state = sender.state.toggle()
            return
        }
        
        Settings.shared.protocolSettings.setIgnorance(
            ignorance: ignorance,
            value: sender.state == .on
        )
        
        updateConvertedText(sampleSourceTextView.string)
    }
}

extension NSControl.StateValue {
    func toggle() -> NSControl.StateValue {
        switch self {
        case .on:
            return .off
        case .off:
            return .on
        case .mixed:
            fatalError()
        default:
            fatalError()
        }
    }
    
    init(isOn: Bool) {
        if isOn == true {
            self = .on
        } else {
            self = .off
        }
    }
}

extension ProtocolViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        updateConvertedText(sampleSourceTextView.string)
    }
}
