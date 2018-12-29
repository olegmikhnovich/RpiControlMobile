//
//  ConnectivityViewController.swift
//  RpiControl Mobile
//
//  Created by Oleg Mikhnovich on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import UIKit

class ConnectivityViewController: UIViewController {
    @IBOutlet weak var directNameLabel: UILabel!
    @IBOutlet weak var directIPLabel: UILabel!
    @IBOutlet weak var directMacLabel: UILabel!
    
    private var device: Device?
    
    override func viewDidLoad() {
        let controlPanelInstance = self.parent as! ControlPanelViewController
        self.device = controlPanelInstance.getDevice()
        
        freshDirectConnBtn([Any]())
    }
    
    @IBAction func freshDirectConnBtn(_ sender: Any) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "get-eth-connection", content: "...")) {
                if res.getHeader() == "get-eth-connection" {
                    let data = res.getContent().split(separator: "|")
                    if data.count == 3 {
                        directNameLabel.text = "Name: \(String(data[0]))"
                        directIPLabel.text = "IP: \(String(data[1]))"
                        directMacLabel.text = "MAC: \(String(data[2]))"
                    }
                }
            }
        }
        connection.dispose()
    }
}
