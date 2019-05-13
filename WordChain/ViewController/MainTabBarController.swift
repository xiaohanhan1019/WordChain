//
//  MainTabBarController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/19.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController , UITabBarControllerDelegate {
    
    var isLogin: Bool {
        return UserDefaults.standard.object(forKey: "userId") != nil
    }
    
    var _lastSelectedIndex: NSInteger!
    var lastSelectedIndex: NSInteger {
        if _lastSelectedIndex == nil {
            _lastSelectedIndex = NSInteger()
            //判断是否相等,不同才设置
            if (self.selectedIndex != selectedIndex) {
                //设置最近一次
                _lastSelectedIndex = self.selectedIndex;
            }
            //调用父类的setSelectedIndex
            super.selectedIndex = selectedIndex
        }
        return _lastSelectedIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBarController?.hidesBottomBarWhenPushed = true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //获取选中的item
        let tabIndex = tabBar.items?.firstIndex(of: item)
        if tabIndex != self.selectedIndex {
            //设置最近一次变更
            _lastSelectedIndex = self.selectedIndex
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController != self.viewControllers![0]  {
            if !isLogin {
                self.selectedIndex = _lastSelectedIndex
                //从StoryBoard加载UI
                let sb = UIStoryboard(name: "Main", bundle:nil)
                let vc = sb.instantiateViewController(withIdentifier: "login") as! UINavigationController
                self.viewControllers![selectedIndex].present(vc, animated: true, completion: nil)
                return false
            } else {
                if let viewController = viewController as? UserInfoTableViewController {
                    viewController.user = nil
                }
                return true
            }
        }
        return true
    }
    
}
