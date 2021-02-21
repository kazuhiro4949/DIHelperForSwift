//
//  DummyViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/14.
//  
//

import Cocoa
import SwiftSyntax

class DummyViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var sampleSourceTextView: NSTextView!
    @IBOutlet weak var convertedSourceTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        sampleSourceTextView.string = SampleParsedSource.protocolSample
        updateConvertedText(sampleSourceTextView.string)
        
        nameTextField.stringValue = Settings
            .shared
            .dummySettings
            .nameFormat ?? ""
        
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
    
    private func updateConvertedText(_ text: String) {
        do {
            
            let sourceFile = try SyntaxParser.parse(
                source: text
            )
            
            let generater = MockGenerater(mockType: .dummy)
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
}
