//
//  DeviceSettingsViewController.swift
//  RpiControl Mobile
//
//  Created by Oleg Mikhnovich on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import UIKit

class DeviceSettingsViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var osLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var soundVolSlider: UISlider!
    
    private var device: Device?
    
    override func viewDidLoad() {
        let controlPanelInstance = self.parent as! ControlPanelViewController
        self.device = controlPanelInstance.getDevice()
        
        loadMyDeviceInfo()
        loadSoundVolumeInfo()
    }
    
    private func loadMyDeviceInfo() {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "device-info", content: "...")) {
                if res.getHeader() == "device-info" {
                    let d = res.getContent().split(separator: "|")
                    if d.count == 4 {
                        nameLabel.text = "Name: \(String(d[0]))"
                        modelLabel.text = "Model: \(String(d[1]))"
                        osLabel.text = "OS: \(String(d[2]))"
                        tempLabel.text = "Temp: \(String(d[3]))"
                    }
                }
            }
        }
        connection.dispose()
    }
    
    private func loadSoundVolumeInfo() {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "get-sound-volume", content: "...")) {
                if res.getHeader() == "get-sound-volume" {
                    soundVolSlider.value = Float(res.getContent()) ?? 0
                }
            }
        }
        connection.dispose()
    }
}
