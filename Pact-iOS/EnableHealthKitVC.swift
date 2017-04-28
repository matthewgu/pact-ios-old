//
//  EnableHealthKitVC.swift
//  Pact-iOS
//
//  Created by matt on 2017-04-06.
//  Copyright © 2017 matt. All rights reserved.
//

import UIKit

class EnableHealthKitVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func enableHealthKitBtnPressed(_ sender: Any) {
        getAuthorized()
    }

    func getAuthorized()
    {
        // Check Authorization
        HealthKitUtil.sharedInstance.checkAuthorization { (authorized) in
            
            if authorized
            {
                DispatchQueue.main.async {
                    print("Authorized")
                    // Go to HomeVC
                    self.performSegue(withIdentifier: "HomeSegue", sender: nil)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    print("Not authorized")
                }
            }
        }
    }

}
