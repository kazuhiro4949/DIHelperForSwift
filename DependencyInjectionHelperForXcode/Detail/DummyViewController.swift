//
//  DummyViewController.swift
//  DependencyInjectionHelperForXcode
//
//  Created by Kazuhiro Hayashi on 2021/02/14.
//  
//

import Cocoa

class DummyViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.stringValue = Settings
            .shared
            .dummySettings
            .nameFormat ?? ""
        
    }
    
    @IBAction func textFieldDidChangeValue(_ sender: NSTextField) {
        let value = sender.stringValue.isEmpty ? nil : sender.stringValue
        Settings.shared.spySettings.nameFormat = value
    }
}
