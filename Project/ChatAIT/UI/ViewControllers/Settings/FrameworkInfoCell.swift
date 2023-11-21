//
//  FrameworkInfoCell.swift
//  ChatAIT
//
//  Created by developer on 21.11.2023.
//

import UIKit

class FrameworkInfoCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }

    func setup(with frameworkInfo: Bundle.AboutInfo) {
        info = frameworkInfo

        if nil != nameLabel {
            updateUI()
        }
    }

    private func updateUI() {
        if let info = info {
            nameLabel.text = info.name
            infoLabel.text = info.version + (nil != info.copyright ? "\n\(info.copyright ?? "")" : "")
        } else {
            nameLabel.text = "unknown".localized
            infoLabel.text = ""
        }
    }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!

    private var info: Bundle.AboutInfo?
}
