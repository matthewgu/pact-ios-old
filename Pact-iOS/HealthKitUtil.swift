//
//  HealthKitUtil.swift
//  Pact-iOS
//
//  Created by matt on 2017-04-09.
//  Copyright © 2017 matt. All rights reserved.
//


import UIKit
import HealthKit

class HealthKitUtil
{
    static var sharedInstance = HealthKitUtil()
    private init() {} // Singleton
    
    lazy var healthStore = HKHealthStore()
    
    func getStep(completion: @escaping (_ success: Bool, _ totalSteps: Int) -> Void)
    {
        // Define the step quantity Type
        guard let qualityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(false, 0)
            return
        }
        
        // Set end date (=now)
        let endDt = Date()
        
        var startDt: Date
        
        // If the last fetched Data was not set in the userDefault
        if UserAccount.sharedInstance.LastFetchedDataOfStep == 0.0
        {
            // Set start date(=3 days ago)
            guard let dt = Calendar.current.date(byAdding: .day, value: -3, to: endDt) else {
                completion(false, 0)
                return
            }
            print("Not fetched step yet.")
            startDt = dt
        }
        else
        {
            // Get last fetched date as double since we are saved date as timeStamp
            let lastFetchedDataTypeDouble = UserAccount.sharedInstance.LastFetchedDataOfStep
            
            // Convert double(timestamp) to Date
            let lastFetchedData = Date(timeIntervalSince1970: lastFetchedDataTypeDouble)
            
            // Set start date(=Last fetched date)
            print("Last fetched date is " + "\(lastFetchedData)")
            startDt = lastFetchedData
        }
        
        // Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: startDt, end: endDt, options: .strictStartDate)
        
        // Interval
        var interval = DateComponents()
        interval.day = 1
        
        // Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: qualityType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDt, intervalComponents: interval)
        
        // Result handler
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                completion(false, 0)
                return
            }
            
            // Save the last fetched date to the user Default
            let doubleDate = endDt.timeIntervalSince1970
            UserAccount.sharedInstance.LastFetchedDataOfStep = doubleDate
            
            // Count up step
            var steps = 0 as Double
            if let rst = results {
                rst.enumerateStatistics(from: startDt, to: endDt) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity()
                    {
                        // Get total steps
                        steps += quantity.doubleValue(for: HKUnit.count())
                        print("\(steps) pts from \(statistics.startDate) to \(statistics.endDate).")
                    }
                }
            }
            
            completion(true, Int(steps))
        }
        
        healthStore.execute(query)
    }
    
    
    // MARK: - Suppport
    func checkAuthorization(completion: @escaping (_ anthorized: Bool) -> Void)
    {
        // Check if healthKit is available
        if HKHealthStore.isHealthDataAvailable()
        {
            // Get quality type
            guard let qualityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                completion(false)
                return
            }
            
            // Check authorization
            healthStore.requestAuthorization(toShare: nil, read: [qualityType]) { (success, error) -> Void in
                if error != nil {
                    completion(false)
                    return
                }
                
                completion(success)
            }
        }
        else
        {
            completion(false)
        }
    }
}
