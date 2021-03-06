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

class HomeVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    let scrlv = UIScrollView()
    
    let pageControl = UIPageControl()
    
    var ref: FIRDatabaseReference!
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    var projects = [Project]()
    var MAX_PAGE = 4
    let MIN_PAGE = 0
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        let title = NSLocalizedString("Pull To Refresh", comment: "Pull to refresh")
        refreshControl.attributedTitle = NSAttributedString(string: title)
        refreshControl.addTarget(self,
                                 action: #selector(refreshOptions(sender:)),
                                 for: .valueChanged)
        scrollView.refreshControl = refreshControl

        
        // fetch user current points
        fetchPoints()
        
        // fetch user project data
        fetchProject { (true) in
            print(self.projects.count)
            self.initViews()
            //self.addView()
        }
    }
    
    private func initViews()
    {
        // Scroll View
        scrlv.frame = CGRect(x: 15, y: view.frame.size.height - 380 - 64, width:  self.view.frame.size.width - 30, height: CGFloat(380))
        scrlv.bounces = true
        scrlv.isPagingEnabled = true
        scrlv.isScrollEnabled = false
        scrlv.delegate = self
        scrlv.clipsToBounds = false
        self.scrollView.addSubview(scrlv)
        
        let projectArrCount = projects.count
        MAX_PAGE = projectArrCount - 1
        
        var x = 0 as CGFloat
        for i in 0..<projectArrCount
        {
            // Base View
            let v = UIView()
            v.backgroundColor = getRandomColor()
            v.frame = CGRect(x: x, y: 0, width: self.scrlv.frame.size.width, height: CGFloat(380))
            scrlv.addSubview(v)
            
            // Project View
            if let project = UINib(nibName: "Project", bundle: nil).instantiate(withOwner: self, options: nil).first as? ProjectView {
                let projectDetails: Project = projects[i]
                project.updateProjectView(project: projectDetails)
                v.addSubview(project)
                project.frame = CGRect(x: 10, y: 10, width: (v.frame.size.width) - 20, height: (v.frame.size.width) - 20)
            }
            
            // Adjust size
            x = v.frame.maxX
            scrlv.contentSize.width = x
        }
    }
    
    func printHello(sender: UIButton) {
        print("hello project view \(sender.tag)")
    }
    
    @IBAction func detectSwipe (_ sender: UISwipeGestureRecognizer) {
        if (currentPage < MAX_PAGE && sender.direction == UISwipeGestureRecognizerDirection.left) {
            moveScrollView(direction: 1)
            
        }
        
        if (currentPage > MIN_PAGE && sender.direction == UISwipeGestureRecognizerDirection.right) {
            moveScrollView(direction: -1)
        }
    }
    
    func moveScrollView(direction: Int){
        currentPage = currentPage + direction
        let point: CGPoint = CGPoint(x: scrlv.frame.size.width * CGFloat(currentPage), y: 0.0)
        scrlv.setContentOffset(point, animated: true)
    }
    
    
    // MARK: - Support
    func getRandomColor() -> UIColor
    {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    // add view
    func addView() {
        if let project = UINib(nibName: "Project", bundle: nil).instantiate(withOwner: self, options: nil).first as? ProjectView {
            
            //let projectIndex = 0
            project.translatesAutoresizingMaskIntoConstraints = false
            self.scrollView.addSubview(project)
            
            //project.pointsLabel.text = self.projects[0].pointsNeeded! + " pts"
            //let projectNameID = self.projects[0].
            print(projects[0].projectNameID!)
            project.layer.cornerRadius = 6
            project.layer.masksToBounds = true
            
            project.contributeButton.layer.cornerRadius = 6
            //project.contributeButton.clipsToBounds = true
            
            // view constraint
            project.leadingAnchor.constraint(equalTo: scrlv.leadingAnchor, constant: 15).isActive = true
            project.trailingAnchor.constraint(equalTo: scrlv.trailingAnchor, constant: -15).isActive = true
            project.heightAnchor.constraint(equalToConstant: projectHeightConstraintConstant()).isActive = true
            project.bottomAnchor.constraint(equalTo: scrlv.bottomAnchor, constant: -70).isActive = true
            
            //project.contributeButton.tag = projectIndex
            //project.contributeButton.addTarget(self, action: #selector(HomeVC.contributeBtnPressed(sender:)), for: .touchUpInside)
        }
    }

    // contribute button pressed
    func contributeBtnPressed(sender: UIButton) {
        fetchPoints()
        
        var currentPoints = Int()
        var pointsNeeded = Int()
        let projectIndex = sender.tag
        var projectContributeCount = Int()
        var projectNameID = String()
        
        if let currentPointsOptional = Int(totalPointsLabel.text ?? "0"), let pointsNeededOptional = Int(projects[projectIndex].pointsNeeded ?? "0"), let projectNameIDOptional = String(projects[projectIndex].projectNameID ?? "name") {
            currentPoints = currentPointsOptional
            pointsNeeded = pointsNeededOptional
            projectNameID = projectNameIDOptional
        }
        
        if currentPoints >= pointsNeeded {
            fetchProjectContriuteCount(projectNameID: projectNameID, projectIndex: projectIndex)
            
            if let projectContributeCountOptional = Int(projects[projectIndex].projectContributeCount ?? "0") {
                projectContributeCount = projectContributeCountOptional
            }
            
            let newPoints = currentPoints - pointsNeeded
            projectContributeCount = projectContributeCount + 1
            
            let projectContributeCountString = "\(projectContributeCount)"
            let newPointsString = "\(newPoints)"
            
            ref = FIRDatabase.database().reference()
            self.ref.child("users/\(uid!)/projects/\(projectNameID)/projectContributeCount/").setValue(projectContributeCountString)
            self.ref.child("users/\(uid!)/points").setValue(newPointsString)
            
            //fetch new points
            fetchProjectContriuteCount(projectNameID: projectNameID, projectIndex: projectIndex)
            fetchPoints()
            
        } else {
            // Not enough points alert
            let alert = UIAlertController(title: "Not Enough Points", message: "Try Again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }



    }
    
    // fetch project - single event
    func fetchProject(completion: @escaping (Bool) -> ()) {
        FIRDatabase.database().reference().child("users").child(uid!).child("projects").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let dict = snap.value as? [String: Any] {
                        if let title = dict["title"] as? String, let pointsNeeded = dict["pointsNeeded"] as? String, let projectNameID = dict["projectNameID"] as? String, let projectContributeCount = dict["projectContributeCount"] as? String, let coverImage = dict["coverImage"] as? String {
        
                            let project = Project(title: title, pointsNeeded: pointsNeeded, projectNameID: projectNameID, projectContributeCount: projectContributeCount, coverImage: coverImage)
                            print("coverImage name: \(project.coverImage!)")
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
                self.totalPointsLabel.text = dictionary["points"] as? String
            }
            
        }, withCancel: nil)
    }
    
    func fetchProjectContriuteCount(projectNameID: String, projectIndex: Int) {
        FIRDatabase.database().reference().child("users").child(uid!).child("projects").child(projectNameID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.projects[projectIndex].projectContributeCount = dictionary["projectContributeCount"] as? String
            }
            
        }, withCancel: nil)
    }
    
    func addPoints(steps: Int) {
        //var currentPoints = Int()
        
//        if let currentPointsOptional = Int(totalPointsLabel.text!) {
//            currentPoints = currentPointsOptional
//        }
        
        let currentPointsStr = "\(steps)"
        print("current points: \(currentPointsStr)")
        
        ref = FIRDatabase.database().reference()
        self.ref.child("users/\(uid!)/points").setValue(currentPointsStr)
    }
    
    // MARK: - Data
    func getStep()
    {
        // Check Authorization
        HealthKitUtil.sharedInstance.checkAuthorization { (authorized) in
            
            if authorized
            {
                // Get step
                HealthKitUtil.sharedInstance.getStep(completion: { (success, totalSteps) in
                    if success
                    {
                        // Get past steps and new steps
                        DispatchQueue.main.async {
                            self.addPoints(steps: totalSteps)
                            //print("total steps: " + "\(totalSteps)")
                            //print("---------------------------------")
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            print("Failed to get steps")
                        }
                    }
                })
            }
            else
            {
                DispatchQueue.main.async {
                    print("Not authorized")
                }
            }
        }
    }
    
    // // MARK: - Pull to Refresh Action
    @objc private func refreshOptions(sender: UIRefreshControl) {
        sender.endRefreshing()
        getStep()
        fetchPoints()
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
