//
//  TerminalViewController.swift
//  RpiControl Mobile
//
//  Created by Oleg Mikhnovich on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController {
    @IBOutlet weak var termPanel: UITextView!
    @IBOutlet weak var cmdBox: UITextField!
    
    private var device: Device?
    
    override func viewDidLoad() {
        let controlPanelInstance = self.parent as! ControlPanelViewController
        self.device = controlPanelInstance.getDevice()
        termPanel.text = "~$ "
    }
    
    @IBAction func sendCmdBtn(_ sender: Any) {
        if cmdBox.text == nil { return }
        if cmdBox.text!.count > 0 {
            if cmdBox.text == "clear" {
                termPanel.text = "~$ "
                cmdBox.text = ""
                return
            }
            guard let dev = device else { return }
            let connection = ConnectionAgent(address: dev.getIP())
            if connection.isConnected {
                if let res = connection.sendMessage(package: Package(header: "exec-cmd", content: cmdBox.text!)) {
                    if res.getHeader() == "exec-cmd" {
                        termPanel.text += cmdBox.text! + "\n"
                        let data = NSString(string: res.getContent()).replacingOccurrences(of: "\\n", with: "\n")
                        termPanel.text += data + "\n\n" + "~$ "
                    }
                }
            }
            connection.dispose()
        }
        cmdBox.text = ""
    }
    
}
