//
//  HomeVC.swift
//  Pact-iOS
//
//  Created by matt on 2017-04-06.
//  Copyright © 2017 matt. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift


class HomeVC: UIViewController {
    
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var initialConstraints = [NSLayoutConstraint]()
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    
    var projects = [Project]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        let title = NSLocalizedString("Pull To Refresh", comment: "Pull to refresh")
        refreshControl.attributedTitle = NSAttributedString(string: title)
        refreshControl.addTarget(self,
                                 action: #selector(refreshOptions(sender:)),
                                 for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        //// MARK: - Add Project View
        if let project = UINib(nibName: "Project", bundle: nil).instantiate(withOwner: self, options: nil).first as? ProjectView {
            
            project.translatesAutoresizingMaskIntoConstraints = false
            self.scrollView.addSubview(project)

            project.layer.cornerRadius = 6
            project.layer.masksToBounds = true
            
            project.contributeButton.layer.cornerRadius = 6
            //project.contributeButton.clipsToBounds = true

            // view constraint
            let leadingConstraint = project.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15)
            let trailingConstraint = project.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -15)
            let heightConstraint = project.heightAnchor.constraint(equalToConstant: projectHeightConstraintConstant())
            let bottomConstraint = project.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -70)
            
            initialConstraints.append(contentsOf: [leadingConstraint,trailingConstraint,heightConstraint,bottomConstraint])
            
            NSLayoutConstraint.activate(initialConstraints)
        }
        
        // fetch user project data
        fetchProject()
    }
        

    func fetchProject() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        FIRDatabase.database().reference().child("users").child(uid!).child("projects").observe(.childAdded, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject] {
                let project = Project()
                
                // If you use this setter, your class properties must match up with the firebase dictionary keys
                //user.setValuesForKeys(dictionary)
                
                project.title = dictionary["title"] as? String
                project.pointsNeeded = dictionary["pointsNeeded"] as? String
                
                //print(user.name!, user.email!)
                
                print(project.title!, project.pointsNeeded!)
                self.projects.append(project)
                
//                DispatchQueue.main.async {
//                    print(self.projects)
//                }
            }
            
        }, withCancel: nil)
        
    }
    
    // // MARK: - Pull to Refresh Action
    @objc private func refreshOptions(sender: UIRefreshControl) {
        sender.endRefreshing()
        totalPointsLabel.text = "10000"
    }
    
    //   Project View Height constraint based on device screen height
    func projectHeightConstraintConstant() -> CGFloat {
        switch(UIScreen.main.fixedCoordinateSpace.bounds.height) {
        case 568:
            return 300
        default:
            return 340
        }
    }
    
    // // MARK: - Sign Out Button Pressed
    @IBAction func signOutBtnPressed(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            DataService().KeyChain.delete("uid")
            // dimiss view & return to root
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out:", signOutError)
        }
    }

}
