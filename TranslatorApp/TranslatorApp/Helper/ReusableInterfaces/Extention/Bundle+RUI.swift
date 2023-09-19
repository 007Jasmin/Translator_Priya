//
//  Bundle+RUI.swift
//  Simple Demo
//
//  Created by Sagar Lukhi on 28/12/22.
//

import Foundation
import UIKit

extension Bundle {
    private static var bundle: Bundle!

    public static func localizedBundle() -> Bundle! {
        if bundle == nil {
            let appLang = UserDefaults.standard.string(forKey: "App_LANGUAGE_KEY") ?? "en"
            let path = Bundle.main.path(forResource: appLang, ofType: "lproj")
            bundle = Bundle(path: path!)
        }

        return bundle
    }

    public static func setLanguage(lang: String) {
        UserDefaults.standard.set(lang, forKey: "App_LANGUAGE_KEY")
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        bundle = Bundle(path: path!)
    }
}

// MARK: - String extension
extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: "", comment: "")
    }

    func localizeWithFormat(arguments: CVarArg...) -> String {
        return String(format: self.localized(), arguments: arguments)
    }
}
