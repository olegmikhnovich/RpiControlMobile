//
//  SearchDevices.swift
//  RpiControl Mobile
//
//  Created by Admin on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Foundation

class SearchDevices {
    
    public func getDevices() -> [Device] {
        var devices = [Device]()
        let addresses = getIFAddresses()
        let queue = OperationQueue()
        queue.addOperation {
            for range in addresses {
                devices.append(contentsOf: self.requestHost(range: range))
            }
        }
        queue.waitUntilAllOperationsAreFinished()
        return devices
    }
    
    func requestHost(range: String) -> [Device] {
        var devices = [Device]()
        let pref = self.getAddressRange(address: range)
        let queue = OperationQueue()
        for i in 1..<256 {
            queue.addOperation {
                let connection = ConnectionAgent(address: "\(pref).\(i)")
                if connection.isConnected {
                    let req = Package(header: "scanner", content: "mikhnovich.oleg.rpicontrol")
                    if let resp = connection.sendMessage(package: req) {
                        if resp.getHeader() == "scanner" {
                            devices.append(Device(raw: resp.getContent(), ip: "\(pref).\(i)"))
                        }
                    }
                }
                connection.dispose()
            }
        }
        queue.waitUntilAllOperationsAreFinished()
        return devices
    }
    
    private func getAddressRange(address: String) -> String {
        var addr = address.split(separator: ".")
        addr.remove(at: 3)
        return addr.joined(separator: ".")
    }
    
    private func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        
        var result = [String]()
        for addr in addresses {
            let match = addr.matches(pattern: "([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4}|(\\d{1,3}\\.){3}\\d{1,3}")
            if match.count > 0 {
                result.append(match[0])
            }
        }
        return result
    }
}
