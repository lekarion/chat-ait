//
//  AboutViewController.swift
//  ChatAIT
//
//  Created by developer on 17.11.2023.
//

import UIKit

class AboutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let infoDictionary = Bundle.main.infoDictionary
        let localizedInfoDictionary = Bundle.main.localizedInfoDictionary

        if let displayName = localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            appNameLabel.text = displayName
        } else {
            appNameLabel.text = (infoDictionary?["CFBundleName"] as? String) ?? ""
        }

        appVersionLabel.text = "Version %@ (%@)".localizedFormat((infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0", (infoDictionary?["CFBundleVersion"] as? String) ?? "1")
        appCopyrightLabel.text = (localizedInfoDictionary?["NSHumanReadableCopyright"] as? String) ?? ""
    }

    @IBOutlet private weak var appNameLabel: UILabel!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var appCopyrightLabel: UILabel!
}
