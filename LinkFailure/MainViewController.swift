//
//  MainViewController.swift
//  LinkFailure
//
//  Created by Barry P. Medoff on 8/31/20.
//  Copyright © 2020 Transition Technology Ventures, LLC. All rights reserved.
//

import UIKit
import WebKit

class MainViewController: UIViewController {

    
    enum SegueName: String {
        case BrokenOnCatalyst       = "BrokenOnCatalyst"
        case WorkAround             = "WorkAround"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier,
            let segueName = SegueName(rawValue: identifier) {
            
            switch(segueName) {
            
                
            case .BrokenOnCatalyst:
                if let destinationVC = segue.destination as? InformationViewController {
                    destinationVC.informationViewType = .BrokenOnCatalyst
                }
                
            case .WorkAround:
                if let destinationVC = segue.destination as? InformationViewController {
                    destinationVC.informationViewType = .WorkAround
                }
                
            }
        }
    }


}
