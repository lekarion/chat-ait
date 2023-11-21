//
//  Bundle+FrameworksInfo.swift
//  ChatAIT
//
//  Created by developer on 21.11.2023.
//

import Foundation

extension Bundle {
    struct AboutInfo {
        let name: String
        let bundleName: String
        let version: String
        let copyright: String?
    }

    var aboutInfo: AboutInfo {
        let infoDictionary = infoDictionary
        let localizedInfoDictionary = localizedInfoDictionary

        let name: String
        let version: String
        let copyright: String?

        if let displayName = localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            name = displayName
        } else {
            name = (infoDictionary?["CFBundleName"] as? String) ?? ""
        }

        version = "Version %@ (%@)".localizedFormat((infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0", (infoDictionary?["CFBundleVersion"] as? String) ?? "1")
        copyright = (localizedInfoDictionary?["NSHumanReadableCopyright"] as? String)

        return AboutInfo(name: name, bundleName: bundleURL.lastPathComponent, version: version, copyright: copyright)
    }

    var bundleFrameworks: [Bundle]? {
        var result = [Bundle]()
        if let privateFrameworksURL = self.privateFrameworksURL, let content = Self.frameworkBundles(at: privateFrameworksURL) {
            result.append(contentsOf: content)
        }

        if let sharedFrameworksURL = self.sharedFrameworksURL, let content = Self.frameworkBundles(at: sharedFrameworksURL) {
            result.append(contentsOf: content)
        }

        return result.isEmpty ? nil : result
    }
}

private extension Bundle {
    static func frameworkBundles(at url: URL) -> [Bundle]? {
        let content = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]).compactMap {
            $0.pathExtension == "framework" ? Bundle(url: $0) : nil
        }

        return (content?.isEmpty ?? true) ? nil : content
    }
}
