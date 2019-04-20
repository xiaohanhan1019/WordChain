//
//  LoginViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/19.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var alertToast: UIAlertController? = nil
    let alertShowTime = 0.8
    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = self.navigationController?.navigationBar
        //导航栏颜色
        nav?.barTintColor = UIColor.white
        //去掉导航栏下边框
        nav?.shadowImage = UIImage()
        //设置左上角返回键,设置大小
        let exitBtn = UIButton(type: .custom)
        exitBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        exitBtn.setImage(UIImage(named:"exit"), for: .normal)
        exitBtn.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        let exitBarItem = UIBarButtonItem(customView: exitBtn)
        let currWidth = exitBarItem.customView?.widthAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        let currHeight = exitBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = exitBarItem
        exitBtn.addTarget(self, action: #selector(self.exitClick), for: UIControl.Event.touchUpInside)
        //去掉后退键文字
        let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item
        
        self.title = "登录"
    }
    
    // 退出
    @objc func exitClick (button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 点击登录键
    @IBAction func login(_ sender: Any) {
        resignFirstResponder()
        if let account = accountTextField.text, let password = passwordTextField.text {
            if account.isEmpty || password.isEmpty {
                alertToast = UIAlertController(title: "请填写用户名和密码", message: nil, preferredStyle: .alert)
                present(alertToast!, animated: true, completion: nil)
                // 1秒后消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + alertShowTime) {
                    self.alertToast!.dismiss(animated: true, completion: nil)
                }
            } else {
                login(account: account, password: password)
                alertToast = UIAlertController(title: "登录中...", message: nil, preferredStyle: .alert)
                present(alertToast!, animated: true, completion: nil)
            }
        }
    }
    
    //http://47.103.3.131:5000/login
    func login(account: String, password: String)
    {
        let session = URLSession(configuration: .default)
        
        let json = ["account":account, "password":password]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://47.103.3.131:5000/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = session.dataTask(with: request) {  [weak self] (data: Data?, response, error) in
            if let error = error {
                print("error: \(error)")
                // TODO 获取不到UI反馈
            } else {
                if let response = response as? HTTPURLResponse, let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("statusCode: \(response.statusCode)")
                    print("data: \(dataString)")
                    if response.statusCode == 200 {
                        let user = try! JSONDecoder().decode(User.self, from: data)
                        UserDefaults.standard.set(user.id, forKey: "userId")
                        DispatchQueue.main.async {
                            // 取消之前登录中弹窗
                            self?.alertToast?.dismiss(animated: false) {
                                // 回到原来界面
                                self?.dismiss(animated: true, completion: nil)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            // 取消之前登录中弹窗,必须之前的dismiss完毕才能有新的弹窗
                            self?.alertToast?.dismiss(animated: false) {
                                //告知失败
                                let failAlertToast = UIAlertController(title: "登录失败", message: nil, preferredStyle: .alert)
                                self?.present(failAlertToast, animated: true, completion: nil)
                                // 1秒后消失
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self!.alertShowTime) {
                                    failAlertToast.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
}
