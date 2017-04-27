//
//  ProjectView.swift
//  Pact-iOS
//
//  Created by matt on 2017-04-11.
//  Copyright © 2017 matt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ProjectView: UIView {
    @IBOutlet weak var contributeButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var projectCoverImage: UIImageView!
    
    func updateProjectView(project: Project) {
        pointsLabel.text = project.pointsNeeded! + " pts"
        projectTitle.text = project.title
        contributeButton.layer.cornerRadius = 6
        contributeButton.backgroundColor = UIColor.brown
    
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let imageName = project.coverImage
        let imageRef = storageRef.child(imageName!)
        
        imageRef.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                guard let imageData = UIImage(data: data!) else { return }
                
                DispatchQueue.main.async {
                    self.projectCoverImage.image = imageData
                }
                
            }).resume()
            
        })
  
    }
    
}
