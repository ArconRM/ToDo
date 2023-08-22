//
//  Extension+String.swift
//  ToDo
//
//  Created by Артемий on 08.01.2023.
//

import Foundation

extension String {
    func localized() -> String {
        NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle: .main,
            value: self,
            comment: self
        )
    }
}
