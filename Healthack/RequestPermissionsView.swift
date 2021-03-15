//
//  RequestPermissionsView.swift
//  Healthack
//
//  Created by Michael Schinis on 15/03/2021.
//

import SwiftUI

struct RequestPermissionsView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var hasError = false
    @State private var requestPermissionError: Error? = nil
    
    var body: some View {
        Button(action: {
            healthKitManager.requestPermissions {
                healthKitManager.checkPermissions()
            } failedHandler: { (error) in
                requestPermissionError = error
                hasError = true
            }
        }, label: {
            Text("Request permissions")
        })
        .alert(isPresented: $hasError, content: {
            Alert(
                title: Text("Error occurred"),
                message: Text("\(requestPermissionError?.localizedDescription ?? "")"),
                dismissButton: Alert.Button.default(Text("OK"), action: {
                    requestPermissionError = nil
                    hasError = false
                })
            )
        })
        
    }
}

struct RequestPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        RequestPermissionsView()
            .environmentObject(HealthKitManager.shared)
    }
}
