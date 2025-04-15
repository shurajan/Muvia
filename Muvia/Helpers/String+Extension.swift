//
//  String+Extension.swift
//  Muvia
//
//  Created by Alexander Bralnin on 15.04.2025.
//

extension String {
    func removingInterfaceSpecifier() -> String {
        if let percentIndex = firstIndex(of: "%") {
            return String(prefix(upTo: percentIndex))
        }
        return self
    }
}
