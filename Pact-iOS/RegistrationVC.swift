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

class RegistrationVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
