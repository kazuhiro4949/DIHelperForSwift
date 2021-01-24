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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.stringValue = Settings.shared.protocolSettings.nameFormat
        
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
}
