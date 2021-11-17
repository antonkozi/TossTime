//
//  TablesViewModel.swift
//  Toss_Time
//
//  Created by Ryan Ahrari on 11/11/21.
//

import Foundation
import FirebaseFirestore

class TablesViewModel: ObservableObject {
    @Published var tables = [Table]()

    private var db = Firestore.firestore()
    
    func fetchData() {
        db.collection("Tables").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.tables = documents.map { (queryDocumentSnapshot) -> Table in
                let data = queryDocumentSnapshot.data()
                
                let contact = data["contactInfo"] as? String ?? ""
                let rules = data["houseRules"] as? String ?? ""
                let id = data["id"] as? String ?? ""
                let owner = data["owner"] as? String ?? ""
                let xcoordinate = data["xcoordinate"] as? String ?? ""
                let ycoordinate = data["ycoordinate"] as? String ?? ""
                
                let table = Table( id: id, owner:owner, rules: rules, contact: contact, xcoordinate: xcoordinate, ycoordinate: ycoordinate)
                
                return table
            }

        }
    }
}
