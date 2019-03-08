//
//  TabController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import GoConnector

class TabBarController : UITabBarController, UITabBarControllerDelegate {
    
    let keyTabOrder = "keyTabOrder"

    override func viewDidLoad() {
        if let cc = (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector {
            cc.addCloverConnectorListener(ConnectionListener(cloverConnector: cc, tabBar: self))
        }
        
        self.delegate = self
        setTagsForTabBarItems()
        getTabBarItemsOrder()
    }
    
    override func viewDidAppear(_ animated: Bool) {

        
    }
    override func viewDidDisappear(_ animated: Bool) {

    
    }
    
    class ConnectionListener : DefaultCloverConnectorListener {
        
        var barController: TabBarController
        
        init(cloverConnector: ICloverConnector, tabBar:TabBarController) {
            self.barController = tabBar
            super.init(cloverConnector:cloverConnector)
        }
        
        override func onDeviceConnected() {
            DispatchQueue.main.async {
                self.barController.tabBar.backgroundColor = UIColor.yellow
            }
        }
        override func onDeviceDisconnected() {
            DispatchQueue.main.async {
                self.barController.tabBar.backgroundColor = UIColor.red
            }
        }
        override func onDeviceReady(_ merchantInfo: MerchantInfo) {
            DispatchQueue.main.async {
                self.barController.tabBar.backgroundColor = UIColor.lightGray
            }
        }
        
        override func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
            // override and do nothing in this instance
        }
        
        override func onVerifySignatureRequest(_ signatureVerifyRequest: VerifySignatureRequest) {
            // override to do nothing in this instance
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        var orderedTagItems = [Int]()
        if changed {
            for viewController in viewControllers {
                let tag = viewController.tabBarItem.tag
                orderedTagItems.append(tag)
            }
            UserDefaults.standard.set(orderedTagItems, forKey: keyTabOrder)
        }
    }
    
    
    func setTagsForTabBarItems() {
        var tag = 0
        if let viewControllers = viewControllers {
            for view in viewControllers {
                view.tabBarItem.tag = tag
                tag += 1
            }
        }
    }
    
    
    func getTabBarItemsOrder() {
        var newViewControllerOrder = [UIViewController]()
        if let initialViewControllers = viewControllers {
            if let tabBarOrder = UserDefaults.standard.object(forKey: keyTabOrder) as? [Int] {
                for tag in tabBarOrder {
                    newViewControllerOrder.append(initialViewControllers[tag])
                }
                setViewControllers(newViewControllerOrder, animated: false)
            }
        }
    }
}
