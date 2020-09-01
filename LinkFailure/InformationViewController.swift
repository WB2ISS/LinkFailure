//
//  InformationViewController.swift
//  StationList
//
//  Created by Barry P. Medoff on 4/23/18.
//  Copyright © 2018 Transition Technology Ventures, LLC. All rights reserved.
//

import UIKit
import WebKit

enum InformationViewType: String {
    case BrokenOnCatalyst
    case WorkAround
}

class InformationViewController: UIViewController, WKNavigationDelegate {
    
    var informationViewType: InformationViewType?
    
    @IBOutlet weak var informationView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        informationView.navigationDelegate = self
        // informationView.isOpaque = false
        
        let helpFileName = "HelpFile"
        let htmlPath = Bundle.main.path(forResource: helpFileName, ofType: "html")
        let helpFileURL = URL(fileURLWithPath: htmlPath!)
        
        informationView.loadFileURL(helpFileURL, allowingReadAccessTo: helpFileURL)
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            
            // On iOS/iPadOS canOpenURL(url) returns false for internal (file) URLs
            // On Mac Catalyst canOpenURL(url) returns true for internal (file) URLs
            // This was causing internal links to open in an external browswer on Mac Catalyst
            // Check for "file" scheme (link to internal anchor) and don't open in external browswer
            
            
            switch(informationViewType!) {
            
            case .WorkAround:
                
                if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url), url.scheme != "file" {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
                
            case .BrokenOnCatalyst:
                
                if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
            }
            
        } else {
            decisionHandler(.allow)
        }
    }
}
