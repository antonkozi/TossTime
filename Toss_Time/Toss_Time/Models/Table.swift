//
//  Table.swift
//  Toss_Time
//
//  Created by Ryan Ahrari on 11/11/21.
//

import Foundation

struct Table: Identifiable{
    var id: String = UUID().uuidString
    var owner: String
    var rules: String
    var contact: String
    var xcoordinate: String
    var ycoordinate: String
    
}
