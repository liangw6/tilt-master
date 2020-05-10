//
//  MotionDataProcessor.swift
//  cse562hw2
//
//  Created by Liang Arthur on 5/3/20.
//  Copyright © 2020 Liang Arthur. All rights reserved.
//

import Foundation
import CoreMotion

class MotionDataProcessor : ObservableObject {
    let motion = CMMotionManager()
    let update_freq = 1.0 / 60.0  // 60 Hz
    var save_to_file: URL = getDocumentsDirectory().appendingPathComponent("output.txt")
    var timer : Timer!
    @Published var accelerometer_data = [Double] (repeating: 0, count: 3)
    @Published var gyro_data = [Double] (repeating: 0, count: 3)
    
    init() {
        // assume we have the data available to us
        assert(self.motion.isGyroAvailable)
        assert(self.motion.isAccelerometerAvailable)
    
        // setup gyroscope
        self.motion.gyroUpdateInterval = self.update_freq
        self.motion.startGyroUpdates()
    
        // setup accelerometer
        self.motion.accelerometerUpdateInterval = self.update_freq
        self.motion.startAccelerometerUpdates()
    }
    
    func set_file_url(_ save_to_file: URL) {
        self.save_to_file = save_to_file
    }
    
    func start() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: update_freq, repeats: true) {
            _ in
            if let data = self.motion.accelerometerData {
                self.accelerometer_data = [data.acceleration.x, data.acceleration.y, data.acceleration.z]
               // Use the accelerometer data in your app.
            }
            if let data = self.motion.gyroData {
                self.gyro_data = [data.rotationRate.x, data.rotationRate.y, data.rotationRate.z]
            }
            
            // store in file
            if let fileUpdate = try? FileHandle(forUpdating: self.save_to_file) {
                fileUpdate.seekToEndOfFile()
                fileUpdate.write("Acce: \(self.accelerometer_data[0]) \(self.accelerometer_data[1]) \(self.accelerometer_data[2])\n".data(using: .utf8)!)
                fileUpdate.write("Gyro: \(self.gyro_data[0]) \(self.gyro_data[1]) \(self.gyro_data[2])\n".data(using: .utf8)!)
                fileUpdate.closeFile()
            }
        }
    }
}
