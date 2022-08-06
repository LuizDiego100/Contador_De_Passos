//
//  ViewModel.swift
//  ContadorPassos
//
//  Created by Luiz Andrade on 06/08/2022.
//

import Foundation
import HealthKit

final class ViewModel: ObservableObject {
    private let healthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?
    @Published public var allMySteps: String = "0"
    private var query: HKStatisticsQuery?
    
    func requestAccessToHealthData() {
        let readableTypes: Set<HKSampleType> = [HKQuantityType.quantityType(forIdentifier: .stepCount)!]
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readableTypes) { success, error in
            if success {
                print("Resquest Authorization \(success.description)")
                self.getTodaySteps()
            }
        }
    }
    
    func getTodaySteps() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("Error: Identifier .stepCount")
            return
        }
        
        observerQuery = HKObserverQuery(sampleType: stepCountType, predicate: nil, updateHandler: { query, completionHandler, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // TODO: We will call geyMySteps()
        })
        
        observerQuery.map(healthStore.execute)
    }
    
    private func getMySteps() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        self.query = HKStatisticsQuery(quantityType: stepsQuantityType,
                                       quantitySamplePredicate: predicate,
                                       options: .cumulativeSum,
                                       completionHandler: { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.allMySteps = String(Int(0))
                }
                return
            }
            
            DispatchQueue.main.async {
                self.allMySteps = String(Int(sum.doubleValue(for: HKUnit.count())))
            }
        })
        
        query.map(healthStore.execute)
    }
}
