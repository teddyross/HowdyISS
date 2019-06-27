//
//  VideoController.swift
//  HowdyISS
//
//  Created by Me on 12/3/18.
//  Copyright © 2018 Ross Co. All rights reserved.
//

import UIKit
import WebKit

class VideoController: UIViewController {

    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string:"https://www.ustream.tv/channel/17074538")
        let req = URLRequest(url: url!)
        webView.load(req)
    }
 

}
