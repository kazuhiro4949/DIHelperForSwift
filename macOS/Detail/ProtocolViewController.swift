//
//  ProtocolViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/23.
//  
//

import Cocoa
import SwiftSyntax
import Sourceful

class ProtocolViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    
    @IBOutlet weak var storedPropertyIgnoranceButton: NSButton!
    @IBOutlet weak var computedGetterSetterPropertyButton: NSButton!
    @IBOutlet weak var functionIgnoranceButton: NSButton!
    @IBOutlet weak var initializerIgnoranceButton: NSButton!
    @IBOutlet weak var internalMemberIgnoranceButton: NSButton!
    @IBOutlet weak var overrideMemberIgnoranceButton: NSButton!
    @IBOutlet weak var sampleSourceTextView: SyntaxTextView!
    @IBOutlet weak var convertedSourceTextView: SyntaxTextView!
    @IBOutlet weak var documentationTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupTextView()
        sampleSourceTextView.text = SampleParsedSource.classSample
        updateConvertedText(sampleSourceTextView.text)
        
        nameTextField.stringValue = Settings
            .shared
            .protocolSettings
            .nameFormat ?? ""
        
        setupButtons()
        setupLink()
    }
    
    private func setupLink() {
        let linkAttrValue = NSAttributedString(
            string: "https://bit.ly/3ka9Tdm",
            attributes: [
                .link: URL(string: "https://bit.ly/3ka9Tdm")!,
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
            convertedSourceTextView.text = extracter.protocolDeclSyntaxList.first?.protocolDeclSyntax.description ?? ""
            
            
        } catch _ {}

    }
    
    
    @IBAction func textFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.protocolSettings.nameFormat = value
        updateConvertedText(sampleSourceTextView.text)
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
        
        updateConvertedText(sampleSourceTextView.text)
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

extension ProtocolViewController: SyntaxTextViewDelegate {
    func lexerForSource(_ source: String) -> Lexer {
        SwiftLexer()
    }
    
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        if syntaxTextView == sampleSourceTextView {
           updateConvertedText(sampleSourceTextView.text)
        }
    }
}
