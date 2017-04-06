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
        performSegue(withIdentifier: "HomeSegue", sender: nil)
    }
    
    

}
