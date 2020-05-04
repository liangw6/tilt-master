//
//  ContentView.swift
//  cse562hw2
//
//  Created by Liang Arthur on 5/3/20.
//  Copyright © 2020 Liang Arthur. All rights reserved.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    let data_names = ["x", "y", "z"]
    @ObservedObject var motionData = MotionDataProcessor()
    var body: some View {
        VStack {
            Button(action: {
                    print("button pressed")
                    self.motionData.start()
                }
            ) {
                Text("Start")
            }
            VStack {
                HStack {
                      // 2
                      ForEach(0..<3) { i in
                        // 3
                        VStack {
                          // 4
        //                  Spacer()
                          // 5
                          Rectangle()
                            .fill(Color.green)
                            .frame(width: 20, height: CGFloat(self.motionData.accelerometer_data[i] * 100 ))
                          // 6
                          Text("acce_\(self.data_names[i])")
                            .font(.footnote)
                            .frame(height: 20)
                        }
                    }
                      // 2
                      ForEach(0..<3) { i in
                        // 3
                        VStack {
                          // 4
        //                  Spacer()
                          // 5
                          Rectangle()
                            .fill(Color.green)
                            .frame(width: 20, height: CGFloat(self.motionData.gyro_data[i] * 100 ))
                          // 6
                          Text("gyro_\(self.data_names[i])")
                            .font(.footnote)
                            .frame(height: 20)
                        }
                    }
                }
            }.offset(y: 300)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
