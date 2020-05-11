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
    let max_updates = 60 * 60 * 5   // 60 hz * 60 seconds * 1 minute
    
    var save_to_file: URL = getDocumentsDirectory().appendingPathComponent("output.txt")
    var timer : Timer!
    var tot_updates = 0
    @Published var accelerometer_data = [Double] (repeating: 0, count: 3)
    @Published var gyro_data = [Double] (repeating: 0, count: 3)
    @Published var write_to_file_state = "In Progress"
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
        
        // clear the file
        let str = "Accelerometer and gyro output\n"
        do {
            try str.write(to: self.save_to_file, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("write to file failed!!!")
        }
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
            self.tot_updates += 1
            if (self.tot_updates <= self.max_updates) {
                if let fileUpdate = try? FileHandle(forUpdating: self.save_to_file) {
                    fileUpdate.seekToEndOfFile()
                    fileUpdate.write("Acce: \(self.accelerometer_data[0]) \(self.accelerometer_data[1]) \(self.accelerometer_data[2])\n".data(using: .utf8)!)
                    fileUpdate.write("Gyro: \(self.gyro_data[0]) \(self.gyro_data[1]) \(self.gyro_data[2])\n".data(using: .utf8)!)
                    fileUpdate.closeFile()
                }
                if (self.tot_updates == self.max_updates) {
                    print("finished updates!!!")
                    self.write_to_file_state = "Ready!"
                }
            }
        }
    }
}
