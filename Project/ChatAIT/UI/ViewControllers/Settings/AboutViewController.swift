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

        let aboutInfo = Bundle.main.aboutInfo
        appNameLabel.text = aboutInfo.name
        appVersionLabel.text = aboutInfo.version
        appCopyrightLabel.text = aboutInfo.copyright ?? ""
    }

    @IBOutlet private weak var appNameLabel: UILabel!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var appCopyrightLabel: UILabel!

    // MARK: ### Private ###
    private lazy var frameworks: [Bundle.AboutInfo] = {
        guard let bundleFrameworks = Bundle.main.bundleFrameworks else { return [] }
        return bundleFrameworks.compactMap { $0.aboutInfo }.sorted { $0.name < $1.name }
    }()
}

private extension AboutViewController {
    static let frameworkInfoCellId = "com.about.frameworkInfoCell"
}

extension AboutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        frameworks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.frameworkInfoCellId, for: indexPath) as? FrameworkInfoCell else { return UITableViewCell() }

        cell.setup(with: frameworks[indexPath.row])
        return cell
    }
}

extension AboutViewController: UITableViewDelegate {
}
