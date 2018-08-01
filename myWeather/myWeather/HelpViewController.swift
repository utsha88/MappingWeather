//
//  HelpViewController.swift
//  myWeather
//
//  Created by Utsha Guha on 27-7-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class HelpViewController: UIViewController {
    @IBOutlet weak var helpWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: ConstantString.kHelpStaticWebPage, withExtension: ConstantString.kHelpStaticWebPageFormat)
        helpWebView.loadRequest(URLRequest(url: url!))
    }
}
