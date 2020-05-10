//
//  ContentView.swift
//  cse562hw2
//
//  Created by Liang Arthur on 5/3/20.
//  Copyright © 2020 Liang Arthur. All rights reserved.
//

import SwiftUI
import CoreMotion
import UIKit

struct DocumentPreview: UIViewControllerRepresentable {
    private var isActive: Binding<Bool>
    private let viewController = UIViewController()
    private let docController: UIDocumentInteractionController

    init(_ isActive: Binding<Bool>, url: URL) {
        self.isActive = isActive
        self.docController = UIDocumentInteractionController(url: url)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPreview>) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DocumentPreview>) {
        if self.isActive.wrappedValue && docController.delegate == nil { // to not show twice
            docController.delegate = context.coordinator
            self.docController.presentPreview(animated: true)
        }
    }

    func makeCoordinator() -> Coordintor {
        return Coordintor(owner: self)
    }

    final class Coordintor: NSObject, UIDocumentInteractionControllerDelegate { // works as delegate
        let owner: DocumentPreview
        init(owner: DocumentPreview) {
            self.owner = owner
        }
        func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            return owner.viewController
        }

        func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
            controller.delegate = nil // done, so unlink self
            owner.isActive.wrappedValue = false // notify external about done
        }
    }
}

struct ContentView: View {
    let data_names = ["x", "y", "z"]
    let temp_file_name = "temp_tile_store.txt"
    let url = getDocumentsDirectory().appendingPathComponent("output.txt")
    
    @ObservedObject var motionData = MotionDataProcessor()
    @State private var show_doc = false
    var body: some View {
        VStack {
            Button(action: {
                let str = "Super long string here"
                
                do {
                    try str.write(to: self.url, atomically: true, encoding: String.Encoding.utf8)
                    print("wrote to file at url \(self.url)")
                } catch {
                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                    print("write to file errored!!!")
                }
                
                self.show_doc = true
                
            }) {
                Text("Write File")
            }.background(DocumentPreview($show_doc, url: url))
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

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
