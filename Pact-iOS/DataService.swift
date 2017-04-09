//
//  DataService.swift
//  Pact-iOS
//
//  Created by matt on 2017-04-06.
//  Copyright © 2017 matt. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import KeychainSwift

let DB_BASE = FIRDatabase.database().reference()

class DataService
{
    private var _keyChain = KeychainSwift()
    private var _refDatabase = DB_BASE
    
    var KeyChain: KeychainSwift
    {
        get
        {
            return _keyChain
        }
        set
        {
            _keyChain = newValue
        }
    }
}

