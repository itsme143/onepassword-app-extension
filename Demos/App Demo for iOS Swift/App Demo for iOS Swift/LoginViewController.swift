//
//  LoginViewController.swift
//  App Demo for iOS Swift
//
//  Created by Rad on 2015-05-14.
//  Copyright (c) 2015 Agilebits. All rights reserved.
//

import Foundation

class LoginViewController: UIViewController {

	@IBOutlet weak var onepasswordButton: UIButton!
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var oneTimePasswordTextField: UITextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation:UIStatusBarAnimation.None)
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "login-background.png")!)
		self.onepasswordButton.hidden = (false == OnePasswordExtension.sharedExtension().isAppExtensionAvailable())
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() == false {
			var alertController = UIAlertController(title: "1Password is not installed", message: "Get 1Password from the App Store", preferredStyle: UIAlertControllerStyle.Alert)

			var cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
			alertController.addAction(cancelAction)

			var OKAction = UIAlertAction(title: "Get 1Password", style: .Default) { (action) in
				var dummy = UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/app/1password-password-manager/id568903335")!)
			}

			alertController.addAction(OKAction)
			self.presentViewController(alertController, animated: true, completion: nil)
		}
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}

	@IBAction func findLoginFrom1Password(sender:AnyObject) -> Void {
		OnePasswordExtension.sharedExtension().findLoginForURLString("https://www.acme.com", forViewController: self, sender: sender, completion: { (loginDict, error) -> Void in
			if loginDict == nil {
				if error!.code != Int(AppExtensionErrorCodeCancelledByUser) {
					NSLog("Error invoking 1Password App Extension for find login: %@", error!)
				}
				return
			}
			
			self.usernameTextField.text = loginDict?[AppExtensionUsernameKey] as? String
			self.passwordTextField.text = loginDict?[AppExtensionPasswordKey] as? String

			var generatedOneTimePassword = loginDict[AppExtensionTOTPKey] as? String
			if generatedOneTimePassword != nil {
				self.oneTimePasswordTextField.hidden = false
				self.oneTimePasswordTextField.text = generatedOneTimePassword

				// Important: It is recommended that you submit the OTP/TOTP to your validation server as soon as you receive it, otherwise it may expire.
				let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
				dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
					self.performSegueWithIdentifier("showThankYouViewController", sender: self)
				})
			}

		})
	}
}
