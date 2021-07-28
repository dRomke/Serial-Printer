//
//  main.swift
//  Serial Printer
//
//  Created by Romuald Dufaux on 13/07/2021.
//
// 	Device sometimes locks up with blue & green LED on. See https://stackoverflow.com/questions/37113612/why-does-an-gnu-io-portinuseexception-pop-up-intermittently-but-never-on-the-fi

import Foundation

let availablePorts = ORSSerialPortManager.shared().availablePorts
let serialPort: ORSSerialPort

// MARK: Connect to TTY
print("Connecting to \(availablePorts[0].name)")	// Last TTY plugged in
serialPort = availablePorts[0]
serialPort.baudRate = 9600
serialPort.open()

// MARK: Generate random RFID data
while true {
	var rfidBytes: Data
	let randomChoice = Int.random(in: 0...4)
	
	switch randomChoice {
	case 0:
		// Simulate genuine RFID swipe in 1 out of the 4 cases
		rfidBytes = Data([0x36, 0x39, 0x42, 0x45, 0x42, 0x41, 0x33, 0x44, 0x0D])
		
	case 1:
		// End of RFID swipe
		rfidBytes = Data([0x0D])
		
	case 2:
		// Generate random data of very long random length
		let randomLength = Int.random(in: 1...99)
		rfidBytes = Data((0..<randomLength).map{ _ in UInt8.random(in: 0..<255) })
		
	default:
		// Generate random data of random length
		let randomLength = Int.random(in: 1...9)
		rfidBytes = Data((0..<randomLength).map{ _ in UInt8.random(in: 0..<255) })
	}
	
	// Send it!
	NSLog("Sending \(rfidBytes as NSData)") // rfidBytes.data(using: String.Encoding.ascii)
	let result = serialPort.send(rfidBytes)
	
	// Recover when connection is lost
	if !result {
		print("Connection was lost")
		serialPort.close()
		serialPort.open()
	}
	
	// Sleep for random time (in µs, so sometimes very short!)
	usleep(useconds_t(Int.random(in: 0..<5000000)))
}


//didEncounterError
//serialPort.attemptRecovery(fromError: <#T##Error#>, optionIndex: <#T##Int#>)
