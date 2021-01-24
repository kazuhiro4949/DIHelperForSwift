//
//  ProtocolViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/01/23.
//  
//

import Cocoa

enum Ignorance: Int {
    case storedProperty
    case computedGetterSetterProperty
    case function
    case initializer
    case internalMember
}

class ProtocolViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func textFieldDidChangeValue(_ sender: NSTextField) {
        let value: String
        if sender.stringValue.isEmpty {
            value = "%@Protocol"
        } else {
            value = sender.stringValue
        }
        
        UserDefaults.group.set(value, forKey: "ProtocolName")
    }
    
    
    @IBAction func ignoranceButtonDidClick(_ sender: NSButton) {
        guard let ignorance = Ignorance(rawValue: sender.tag) else {
            sender.state = sender.state.toggle()
            return
        }
        
        UserDefaults.group.set(
            sender.state.rawValue,
            forKey: "Ignorance_\(ignorance.rawValue)")
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
            return .mixed
        default:
            return .mixed
        }
    }
}
