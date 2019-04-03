//
//  WordDetailViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/1.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import WebKit

class WordDetailViewController: UIViewController {
        
   var detailWord: Word?{
        didSet{
            configureView()
        }
    }
    
    func configureView() {
        // TODO
        let wordDetailWebView = WKWebView()
        self.view.addSubview(wordDetailWebView)
        wordDetailWebView.frame = self.view.bounds
        
        let bundlePath = Bundle.main.bundlePath
        
        var path:String
        if detailWord?.name == "acclaim"{
            path = "file://\(bundlePath)/WordChain/a.html"
        } else {
            path = "file://\(bundlePath)/WordChain/b.html"
        }

        
        guard let url = URL(string: path) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        wordDetailWebView.load(request)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
