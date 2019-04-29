//
//  LoginViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/19.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    var alertToast: UIAlertController? = nil
    let alertShowTime = 0.5
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "登录"
        
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
                spinner.startAnimating()
                login(account: account, password: password)
            }
        }
    }
    
    //http://47.103.3.131:5000/login
    func login(account: String, password: String)
    {
        let parameters = ["account": account, "password":password]
        let request = "http://47.103.3.131:5000/login"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode, let data = response.data {
                if statusCode == 200 {
                    let user = try! JSONDecoder().decode(User.self, from: data)
                    UserDefaults.standard.set(user.id, forKey: "userId")
                    DispatchQueue.main.async {
                        self?.spinner.stopAnimating()
                        // 取消之前登录中弹窗
                        self?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.spinner.stopAnimating()
                        let failAlertToast = UIAlertController(title: "账号或密码不正确", message: nil, preferredStyle: .alert)
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
