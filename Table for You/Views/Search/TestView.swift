//
//  TestView.swift
//  Table for You
//
//  Created by Daniel Clauss on 01.10.22.
//

import SwiftUI

struct TestView: View {
    @StateObject var vM = TestVM()
    
    @State private var text = "Unknown"
    
    @State private var counter = 0
    
    var body: some View {
        VStack {
            Toggle("Test", isOn: $vM.state)
            
            Button("Turn On") {
                vM.state = true
            }
            
            Text(text)
                .onReceive(vM.$state) { output in
                    text = output ? "On" : "Off"
                    counter += 1
                }
            Text("\(counter)")
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

class TestVM: ObservableObject {
    @Published var state = true
}
