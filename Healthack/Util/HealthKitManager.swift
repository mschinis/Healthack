//
//  HealthKitManager.swift
//  Healthack
//
//  Created by Michael Schinis on 15/03/2021.
//

import Foundation
import HealthKit

enum HealthKitStatus {
    case loading, shouldRequest, unnecessary, error(Error?)
}

class HealthKitManager: ObservableObject {
    // Permission request
    typealias PermissionRequestSuccessHandler = () -> Void
    typealias PermissionRequestFailedHandler = (Error?) -> Void
    // Permission check
    typealias PermissionCheckShouldRequestHandler = () -> Void
    typealias PermissionCheckUnnecessaryHandler = () -> Void
    typealias PermissionCheckFailedHandler = (Error?) -> Void
    // Add workout
    typealias AddWorkoutSuccessHandler = () -> Void
    typealias AddWorkoutFailedHandler = (Error?) -> Void

    static var shared = HealthKitManager()
    
    private var store = HKHealthStore()
    @Published var status: HealthKitStatus = .loading

    private static var permissions = Set([
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!
    ])
    
    func checkPermissions() {
        DispatchQueue.main.async {
            self.status = .loading
        }

        hasPermissions {
            DispatchQueue.main.async {
                self.status = .shouldRequest
            }
        } unnecessaryHandler: {
            DispatchQueue.main.async {
                self.status = .unnecessary
            }
        } failedHandler: { (error) in
            DispatchQueue.main.async {
                self.status = .error(error)
            }
        }

    }

    func hasPermissions(requestHandler: @escaping PermissionCheckShouldRequestHandler, unnecessaryHandler: @escaping PermissionCheckUnnecessaryHandler, failedHandler: @escaping PermissionCheckFailedHandler) {
        store.getRequestStatusForAuthorization(toShare: Self.permissions, read: Self.permissions) { (status, error) in
            switch status {
            case .unknown: failedHandler(error)
            case .shouldRequest: requestHandler()
            case .unnecessary: unnecessaryHandler()
            @unknown default: fatalError("Unknown permission status received")
            }
        }
    }

    func requestPermissions(successHandler: @escaping PermissionRequestSuccessHandler, failedHandler: @escaping PermissionRequestFailedHandler) {
        store.requestAuthorization(toShare: Self.permissions, read: Self.permissions) { (success, error) in
            if success {
                successHandler()
            } else {
                failedHandler(error)
            }
        }
    }

    func addWorkout(startDate: Date, endDate: Date, totalDistance: HKQuantity, successHandler: @escaping AddWorkoutSuccessHandler, failedHandler: @escaping AddWorkoutFailedHandler) {
        let workout = HKWorkout(activityType: .walking, start: startDate, end: endDate, workoutEvents: nil, totalEnergyBurned: nil, totalDistance: totalDistance, metadata: nil)

        store.save(workout) { (success, error) in
            if success {
                successHandler()
            } else {
                failedHandler(error)
            }
        }
    }
}
