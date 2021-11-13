//
//  tablesViewModel.swift
//  Toss_Time
//
//  Created by Anton Kozintsev on 11/11/21.
//

import Foundation
import FirebaseFirestore

class tablesViewModel{
    @Published var tables = [Table]()
    
    private var db = Firestore.firestore()
    
    func fetchData(){
        db.collection("Tables").addSnapshotListener{(QuerySnapshot, error) in guard let documents = QuerySnapshot?.documents else {
            print("No documents")
            return
        }
        
            self.tables = documents.map { (QueryDocumentSnapshot) -> Table in
                let data = QueryDocumentSnapshot.data()
                
                let owner = data["owner"] as? String ?? ""
                let contactInfo = data["contactInfo"] as? String ?? ""
                let houseRules = data["houseRules"] as? String ?? ""
                
                return Table(owner: owner, houseRules: houseRules, contactInfo: contactInfo)
                
            }
        }
    }
}


