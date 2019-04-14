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

    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var detailWord: Word?
    var html: String?
    var css: String?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureView() {
        let wordDetailWebView = WKWebView()
        self.view.addSubview(wordDetailWebView)
        wordDetailWebView.frame = self.view.bounds
        if let html = html , let css = css {
            self.spinner.stopAnimating()
            wordDetailWebView.loadHTMLString(css+html, baseURL: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spinner.startAnimating()
        getDetail(word: detailWord!.name)
    }
    
    //http://47.103.3.131:5000/searchWord
    func getDetail(word: String)
    {
        let session = URLSession(configuration: .default)
        
        let json = ["word":word]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://47.103.3.131:5000/wordDetail")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = session.dataTask(with: request) { [weak self] (data: Data?, response, error) in
            if let error = error {
                print("error: \(error)")
                // TODO 获取不到UI反馈
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                    let wordDetailHtml = try! JSONDecoder().decode(WordDetailHtml.self, from: data)
                    self?.html = wordDetailHtml.html
                    self?.css = wordDetailHtml.css
                    DispatchQueue.main.async {
                        self?.configureView()
                    }
                }
            }
        }
        task.resume()
    }


}
