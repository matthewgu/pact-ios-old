//
//  UserAccount.swift
//  Pact-iOS
//
//  Created by matt on 2017-04-09.
//  Copyright © 2017 matt. All rights reserved.
//

import UIKit

class UserAccount
{
    static var sharedInstance = UserAccount()
    private init() {} // Singleton
    
    private struct Key {
        static let TotalStep = "UserAccount.TotalStep"
        static let LastFetchedDataOfStep = "UserAccount.LastDataOfFetchStep"
    }
    
    var totalStep: Int {
        get {
            return StorageUtil.intForKey(key: Key.TotalStep)
        }
        set {
            _ = StorageUtil.saveInt(int: newValue, key: Key.TotalStep)
        }
    }
    
    var LastFetchedDataOfStep: Double {
        get {
            return StorageUtil.doubleForKey(key: Key.LastFetchedDataOfStep)
        }
        set {
            _ = StorageUtil.saveDouble(double: newValue, key: Key.LastFetchedDataOfStep)
        }
    }
}

