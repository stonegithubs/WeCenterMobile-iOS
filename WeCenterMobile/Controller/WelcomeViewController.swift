//
//  WelcomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    let loginView = LoginView()
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let welcomeView = WelcomeView()
        welcomeView.loginButton.addTarget(self, action: "showLoginView", forControlEvents: .TouchUpInside)
        typealias AlertAction = Msr.UI.AlertAction
        loginView.addAction(AlertAction(title: welcomeStrings["Cancel"], style: .Cancel) { action in })
        loginView.addAction(AlertAction(title: welcomeStrings["Login"], style: .Default) {
            action in
            User.loginWithName(self.loginView.usernameField.text,
                password: self.loginView.passwordField.text,
                success: {
                    user in
                    appDelegate.currentUser = user
                    appDelegate.mainViewController = MainViewController()
                    appDelegate.mainViewController.modalTransitionStyle = .CrossDissolve
                    appDelegate.window!.rootViewController!.presentViewController(appDelegate.mainViewController, animated: true, completion: nil)
                },
                failure: nil)
            })
        view = welcomeView
        view.addSubview(loginView)
    }
    
    func showLoginView() {
        loginView.show()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
