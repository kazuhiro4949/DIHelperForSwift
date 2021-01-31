//
//  ProtocolViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/23.
//  
//

import Cocoa

class ProtocolViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    
    @IBOutlet weak var storedPropertyIgnoranceButton: NSButton!
    @IBOutlet weak var computedGetterSetterPropertyButton: NSButton!
    @IBOutlet weak var functionIgnoranceButton: NSButton!
    @IBOutlet weak var initializerIgnoranceButton: NSButton!
    @IBOutlet weak var internalMemberIgnoranceButton: NSButton!
    @IBOutlet weak var overrideMemberIgnoranceButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.stringValue = Settings
            .shared
            .protocolSettings
            .nameFormat
        
        setupButtons()
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
    
    @IBAction func textFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? "%@Protocol" : sender.stringValue
        Settings.shared.protocolSettings.nameFormat = value
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
