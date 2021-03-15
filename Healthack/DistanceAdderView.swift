//
//  ContentView.swift
//  Healthack
//
//  Created by Michael Schinis on 15/03/2021.
//

import SwiftUI
import HealthKit

enum DistanceAdderAlertType: Identifiable {
    case success, failed

    var id: String {
        switch self {
        case .success: return "success"
        case .failed: return "failed"
        }
    }
    
    var title: String {
        switch self {
        case .success: return "Added"
        case .failed: return "Error"
        }
    }
    
    var description: String {
        switch self {
        case .success: return "Workout added successfully"
        case .failed: return "Failed adding workout"
        }
    }
}

struct DistanceAdderView: View {
    @State private var startDate = Date().addingTimeInterval(-60*60)
    @State private var endDate = Date()
    @State private var distance = ""
    @State private var alertType: DistanceAdderAlertType? = nil
//    @State private var didAddWorkoutSuccessfully = false
//    @State private var didFailAddingWorkout = false

    @EnvironmentObject var healthKitManager: HealthKitManager

    var body: some View {
        Form {
            Section {
                DatePicker("Start date", selection: $startDate)
                DatePicker("Start date", selection: $endDate)
            }
            
            Section {
                TextField("Distance (m)", text: $distance)
                    .keyboardType(.numberPad)
            }
            
            Section {
                Button(action: didTapAddWorkout, label: {
                    Text("Add workout")
                })
            }
        }
        .alert(item: $alertType, content: { alertType in
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.description),
                dismissButton: .default(Text("OK"), action: {
                    self.alertType = nil
                })
            )
        })
        .navigationTitle("Add distance")
    }

    func didTapAddWorkout() {
        let totalDistance = Double(distance) ?? 0
        let quantity = HKQuantity(unit: .meter(), doubleValue: totalDistance)
        
        healthKitManager.addWorkout(startDate: startDate, endDate: endDate, totalDistance: quantity) {
            self.distance = ""
            self.alertType = .success
        } failedHandler: { (error) in
            self.distance = ""
            self.alertType = .failed
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DistanceAdderView()
                .environmentObject(HealthKitManager.shared)
        }
        
    }
}
