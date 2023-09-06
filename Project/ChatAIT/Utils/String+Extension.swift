//
//  String+Extension.swift
//  ChatAIT
//
//  Created by developer on 06.09.2023.
//

import Foundation

extension String { // custom localization
    var localized: String {
        NSLocalizedString(self, comment: "")
	}

    func localizedFormat(_ args: Any...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: args as! [CVarArg])
    }
}
