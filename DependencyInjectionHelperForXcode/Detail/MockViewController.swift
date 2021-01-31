//
//  MockViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/23.
//  
//

import Cocoa

class MockViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    
    @IBOutlet weak var propertyTargetButton: NSButton!
    @IBOutlet weak var functionTargetButton: NSButton!
    @IBOutlet weak var initializerTargetButton: NSButton!
    
    @IBOutlet weak var calledOrNotCaptureButton: NSButton!
    @IBOutlet weak var callCountCaptureButton: NSButton!
    @IBOutlet weak var passedArgumentCaptureButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.stringValue = Settings
            .shared
            .spySettings
            .nameFormat ?? ""
        
        setupButtons()
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
    
    @IBAction func textFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? "%@Protocol" : sender.stringValue
        Settings.shared.spySettings.nameFormat = value
    }
    
    @IBAction func targetButtonDidClick(_ sender: NSButton) {
        guard let target = Settings.SpySetting.Target(rawValue: sender.tag) else {
            sender.state = sender.state.toggle()
            return
        }
        
        Settings.shared.spySettings.setTarget(
            target: target,
            value: sender.state != .on
        )
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
    }
    
}
