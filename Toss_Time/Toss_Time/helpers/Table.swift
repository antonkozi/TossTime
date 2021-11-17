//
//  Table.swift
//  Toss_Time
//
//  Created by Anton Kozintsev on 11/11/21.
//

import Foundation

struct Table: Identifiable {
    var id: String = UUID().uuidString
    var owner: String
    var houseRules: String
    var contactInfo: String
}
