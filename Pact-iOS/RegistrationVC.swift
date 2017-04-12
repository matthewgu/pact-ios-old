//
//  RegistrationVC.swift
//  Pact-iOS
//
//  Created by matt on 2017-04-06.
//  Copyright © 2017 matt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import KeychainSwift

class RegistrationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signUpButton.layer.cornerRadius = 6
        self.signUpButton.layer.masksToBounds = true

    }

    override func viewDidAppear(_ animated: Bool) {
        let keyChain = DataService().KeyChain
        if keyChain.get("uid") != nil {
            performSegue(withIdentifier: "HealthKitSegue", sender: nil)
        }
    }
    
    func completeSignIn(id: String) {
        let keyChain = DataService().KeyChain
        keyChain.set(id, forKey: "uid")
    }
    
    //dismiss keyword when return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //offsets input field when editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 250), animated: true)
    }
    
    // returns input field to original position when done editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    // loging with firebase
    @IBAction func signUpBtnPressed(_ sender: Any) {
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    self.completeSignIn(id: user!.uid)
                    self.emailField.text = ""
                    self.passwordField.text = ""
                    print("you're logged in")
                    
                    self.performSegue(withIdentifier: "HealthKitSegue", sender: nil)
                } else {
                    
                    //create new user with firebase
                    FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            print(error as Any)
                        } else {
                            self.completeSignIn(id: user!.uid)
                            self.emailField.text = ""
                            self.passwordField.text = ""
                            print("you've created a new account")
                            
                            self.performSegue(withIdentifier: "HealthKitSegue", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
}
