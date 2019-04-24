//
//  WordDetailViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/1.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

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
    
    //http://47.103.3.131:5000/wordDetail
    func getDetail(word: String){
        let parameters = ["word": word]
        let request = "http://47.103.3.131:5000/wordDetail"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                let wordDetailHtml = try! JSONDecoder().decode(WordDetailHtml.self, from: data)
                self?.html = wordDetailHtml.html
                self?.css = wordDetailHtml.css
                DispatchQueue.main.async {
                    self?.configureView()
                }
            }
        }
    }
}
