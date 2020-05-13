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
    let max_updates = 60 * 60 * 5  // 60 hz * 60 seconds * 1 minute
    let complementary_filter_alpha = 0.98
    
    var save_to_file: URL = getDocumentsDirectory().appendingPathComponent("output.txt")
    var timer : Timer!
    var tot_updates = 0
    @Published var accelerometer_data = [Double] (repeating: 0, count: 2)
    @Published var gyro_data = [Double] (repeating: 0, count: 2)
    @Published var complementary_filter_result = [Double] (repeating: 0, count: 2)
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
    
    func get_length(x: Double, y:Double, z:Double) -> Double {
        return sqrt(x*x + y*y + z*z)
    }
    
    func get_length(x: Double, y:Double) -> Double {
        return sqrt(x*x + y*y)
    }
    
    func get_angle(x: Double, y:Double) -> Double {
        return atan2(y, x) * 180 / Double.pi
    }
    
    func start() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: update_freq, repeats: true) {
            _ in
            if let data = self.motion.accelerometerData {
//                self.accelerometer_data = [data.acceleration.x, data.acceleration.y, data.acceleration.z]
                
                // Use the accelerometer data in your app.
                self.accelerometer_data[0] = asin(data.acceleration.y / self.get_length(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)) * 180 / Double.pi
                self.accelerometer_data[1] = asin(data.acceleration.x / self.get_length(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)) * 180 / Double.pi
            }
            
            // curr_gyro_update will update based complementary filter result from the previous round, not the gyro data from the previous
            // round
            var curr_gyro_update = [Double] (repeating: 0, count: 2)
            if let data = self.motion.gyroData {
//                self.gyro_data = [data.rotationRate.x, data.rotationRate.y, data.rotationRate.z]
                curr_gyro_update[0] = data.rotationRate.x * self.update_freq * 180 / Double.pi + self.complementary_filter_result[0]
                curr_gyro_update[1] = data.rotationRate.x * self.update_freq * 180 / Double.pi + self.complementary_filter_result[1]
                // use gyro_data
                self.gyro_data[0] += data.rotationRate.x * self.update_freq * 180 / Double.pi
                self.gyro_data[1] += data.rotationRate.x * self.update_freq * 180 / Double.pi
            }
            
            self.complementary_filter_result[0] = curr_gyro_update[0] * self.complementary_filter_alpha - self.accelerometer_data[0] * (1 - self.complementary_filter_alpha)
            self.complementary_filter_result[1] = curr_gyro_update[1] * self.complementary_filter_alpha - self.accelerometer_data[1] * (1 - self.complementary_filter_alpha)
            
            // store in file
            self.tot_updates += 1
            if (self.tot_updates <= self.max_updates) {
                if let fileUpdate = try? FileHandle(forUpdating: self.save_to_file) {
                    fileUpdate.seekToEndOfFile()
                    fileUpdate.write("Acce: \(self.accelerometer_data[0]) \(self.accelerometer_data[1]) \n".data(using: .utf8)!)
                    fileUpdate.write("Gyro: \(self.gyro_data[0]) \(self.gyro_data[1]) \n".data(using: .utf8)!)
                    fileUpdate.write("Comp: \(self.complementary_filter_result[0]) \(self.complementary_filter_result[1]) \n".data(using: .utf8)!)
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
