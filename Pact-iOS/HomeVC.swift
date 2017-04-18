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
import FirebaseAuth

class HomeVC: UIViewController {
    
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var ref: FIRDatabaseReference!
    let uid = FIRAuth.auth()?.currentUser?.uid
    
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
        
        // add view
        //addView()
        
        // fetch user current points
        fetchPoints()
        
        // fetch user project data
        fetchProject { (true) in
            print(self.projects.count)
            self.addView()
        }
    }
    
    
    // add view
    func addView() {
        if let project = UINib(nibName: "Project", bundle: nil).instantiate(withOwner: self, options: nil).first as? ProjectView {
            
            project.translatesAutoresizingMaskIntoConstraints = false
            self.scrollView.addSubview(project)
            
            project.pointsLabel.text = self.projects[0].pointsNeeded! + " pts"
            project.layer.cornerRadius = 6
            project.layer.masksToBounds = true
            
            project.contributeButton.layer.cornerRadius = 6
            //project.contributeButton.clipsToBounds = true
            
            // view constraint
            project.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15).isActive = true
            project.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -15).isActive = true
            project.heightAnchor.constraint(equalToConstant: projectHeightConstraintConstant()).isActive = true
            project.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -70).isActive = true
            
            project.contributeButton.addTarget(self, action: #selector(HomeVC.contributeBtnPressed(sender:)), for: .touchUpInside)
        }
    }

    // contribute button pressed
    func contributeBtnPressed(sender: UIButton) {
        print("contributed")
    }
    
    // fetch project - single event
    func fetchProject(completion: @escaping (Bool) -> ()) {
        FIRDatabase.database().reference().child("users").child(uid!).child("projects").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let dict = snap.value as? [String: Any] {
                        if let title = dict["title"] as? String, let pointsNeeded = dict["pointsNeeded"] as? String {
        
                            let project = Project(title: title, pointsNeeded: pointsNeeded)
                            self.projects.append(project)
                        }
                    }
                }
            }
            completion(true)
        })
    }
    
    
    // fetch project
//    func fetchProject() {
//        FIRDatabase.database().reference().child("users").child(uid!).child("projects").observe(.value, with: { (snapshot) in
//            //print(snapshot.children.allObjects)
//            
//            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                for snap in snapshot {
//                    if let dict = snap.value as? [String: Any] {
//                        if let title = dict["title"] as? String, let pointsNeeded = dict["pointsNeeded"] as? String {
//                            //print(title, pointsNeeded)
//                            
//                            let project = Project(title: title, pointsNeeded: pointsNeeded)
//                            
//                            self.projects.append(project)
//                        }
//                    }
//                }
//            }
//        })
//    }
//    
    // fetch Project
//    func fetchProject() {
//        
//        FIRDatabase.database().reference().child("users").child(uid!).child("projects").observe(.childAdded, with: { (snapshot) in
//            
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                
//                // If you use this setter, your class properties must match up with the firebase dictionary keys
//                //project.setValuesForKeys(dictionary)
//                
//                let title = dictionary["title"] as? String
//                let pointsNeeded = dictionary["pointsNeeded"] as? String
//                
//                let project = Project(title: title!, pointsNeeded: pointsNeeded!)
//                
//                self.projects.append(project)
//                
//                DispatchQueue.main.async {
//                    print(self.projects.count)
//                    self.addView()
//                }
//                
//            }
//        }, withCancel: nil)
//        
//    }
    
    func fetchPoints() {
        FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.totalPointsLabel.text = dictionary["points"] as? String ?? ""
            }
            
        }, withCancel: nil)
    }
    
    func addPoints() {
        var currentPoints = Int()
        
        if let currentPointsOptional = Int(totalPointsLabel.text ?? "0") {
            currentPoints = currentPointsOptional
        }
        
        let currentPointsStr = "\(currentPoints + 1)"
        print(currentPointsStr)
        
        ref = FIRDatabase.database().reference()
        self.ref.child("users/\(uid!)/points").setValue(currentPointsStr)
    }
    
    // // MARK: - Pull to Refresh Action
    @objc private func refreshOptions(sender: UIRefreshControl) {
        sender.endRefreshing()
        addPoints()
        fetchPoints()
        //totalPointsLabel.text = "10000"
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
