//
//  AppView.swift
//  Healthack
//
//  Created by Michael Schinis on 15/03/2021.
//

import SwiftUI
import HealthKit

struct AppView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager

    var body: some View {
        if HKHealthStore.isHealthDataAvailable() {
            NavigationView {
                startingView()
            }
            .onAppear(perform: {
                healthKitManager.checkPermissions()
            })
        } else {
            Text("HealthKit is not supported on this device")
        }
    }
    
    func startingView() -> some View {
        switch healthKitManager.status {
        case .loading: return AnyView(ProgressView()).id("ProgressView")
        case .shouldRequest: return AnyView(RequestPermissionsView()).id("RequestPermissionsView")
        case .unnecessary: return AnyView(DistanceAdderView()).id("DistanceAdderView")
        case .error(_): return AnyView(Text("An error occurred...")).id("ErrorOccurred")
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .environmentObject(HealthKitManager.shared)
    }
}
