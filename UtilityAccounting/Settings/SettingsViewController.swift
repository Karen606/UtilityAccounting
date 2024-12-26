//
//  SettingsViewController.swift
//  UtilityAccounting
//
//  Created by Karen Khachatryan on 15.12.24.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var darkModeView: UIView!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: BaseSwitch!
    @IBOutlet var settingsSectionLabels: [UILabel]!
    @IBOutlet var settingsSectionView: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        contentView.layer.borderColor = UIColor.fieldBorder.cgColor
        darkModeView.layer.borderColor = UIColor.fieldBorder.cgColor
        settingsSectionView.forEach({ $0.layer.borderColor = UIColor.fieldBorder.cgColor })
        darkModeLabel.text = darkModeSwitch.isOn ? "Light Mode" : "Dark Mode"
    }
    
    func setupUI() {
        setNaviagtionBackButton()
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.fieldBorder.cgColor
        darkModeLabel.font = .medium(size: 18)
        darkModeView.layer.borderWidth = 1
        darkModeView.layer.borderColor = UIColor.fieldBorder.cgColor
        for view in settingsSectionView {
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.fieldBorder.cgColor
        }
        settingsSectionLabels.forEach({ $0.font = .medium(size: 16) })
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        darkModeLabel.text = darkModeSwitch.isOn ? "Light Mode" : "Dark Mode"
    }
    
    @IBAction func chooseDarkMode(_ sender: UISwitch) {
        sender.isOn = sender.isOn
        let interfaceMode = sender.isOn ? UIUserInterfaceStyle.dark : .light
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkModeEnabled")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = interfaceMode
            }
        }
    }
    
    @IBAction func clickedContactUs(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients(["pavlik1719@icloud.com"])
            present(mailComposeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(
                title: "Mail Not Available",
                message: "Please configure a Mail account in your settings.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @IBAction func clickedPrivacyPolicy(_ sender: UIButton) {
        let privacyVC = PrivacyViewController()
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(privacyVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    @IBAction func clickedRateUs(_ sender: UIButton) {
        let appID = "6739880986"
        if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Unable to open App Store URL")
            }
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
