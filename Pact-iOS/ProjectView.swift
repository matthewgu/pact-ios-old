//
//  ProjectView.swift
//  Pact-iOS
//
//  Created by matt on 2017-04-11.
//  Copyright © 2017 matt. All rights reserved.
//

import UIKit

class ProjectView: UIView {
    @IBOutlet weak var contributeButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var projectTitle: UILabel!
    
    func updateProjectView(project: Project) {
        pointsLabel.text = project.pointsNeeded! + " pts"
        projectTitle.text = project.title
        contributeButton.layer.cornerRadius = 6
        contributeButton.backgroundColor = UIColor.brown
    }
    
}
