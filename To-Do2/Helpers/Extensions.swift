//
//  Extensions.swift
//  To-Do2
//
//  Created by User on 2024/05/12.
//

import Foundation


extension String {
    
    static let empty = ""
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
