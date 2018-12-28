//
//  ControlPanelViewController.swift
//  RpiControl Mobile
//
//  Created by Oleg Mikhnovich on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import UIKit

class ControlPanelViewController: UITabBarController {
    private var device: Device?
    
    override func viewDidLoad() {
    }
    
    func setDevice(device: Device) {
        self.device = device
    }
    
    func getDevice() -> Device? {
        return self.device
    }
    
}
