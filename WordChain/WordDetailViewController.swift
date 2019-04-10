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
        
   var detailWord: Word?
    
    func configureView() {
        post()
        // TODO
//        let wordDetailWebView = WKWebView()
//        self.view.addSubview(wordDetailWebView)
//        wordDetailWebView.frame = self.view.bounds
//
//        let bundlePath = Bundle.main.bundlePath
//
//        var path:String
//        if detailWord?.name == "acclaim"{
//            path = "file://\(bundlePath)/a.html"
//        } else {
//            path = "file://\(bundlePath)/b.html"
//        }
//
//
//        guard let url = URL(string: path) else {
//            return
//        }
//
//        let request = URLRequest(url: url)
//
//        wordDetailWebView.load(request)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //http://47.103.3.131:5000/searchWord
    func post()
    {
        let url = URL(string: "http://47.103.3.131:5000/searchWord")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let json = ["search":"claim"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                }
            }
        }
        task.resume()
    }


}
