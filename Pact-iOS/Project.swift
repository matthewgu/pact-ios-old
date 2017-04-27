//
//  Project.swift
//  Pact-iOS
//
//  Created by matt on 2017-04-15.
//  Copyright © 2017 matt. All rights reserved.
//

import UIKit

class Project {
    
    var title: String?
    var pointsNeeded: String?
    var projectNameID: String?
    var projectContributeCount: String?
    var coverImage: String?
    
    init(title: String, pointsNeeded: String, projectNameID: String, projectContributeCount: String, coverImage: String) {
        self.title = title
        self.pointsNeeded = pointsNeeded
        self.projectNameID = projectNameID
        self.projectContributeCount = projectContributeCount
        self.coverImage = coverImage        
    }
}
