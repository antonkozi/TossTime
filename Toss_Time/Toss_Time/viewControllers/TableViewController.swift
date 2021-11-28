//
//  TableViewController.swift
//  Toss_Time
//
//  Created by Steve Beurard on 11/16/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
import CoreLocation

struct tableStruct {
    let id: String!
    let owner: String!
    let contactInfo: String!
    let latitude: Double!
    let longitude: Double!
}

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    var tables = [tableStruct]()
    var selectedCells:[IndexPath] = []
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        fetchTables()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tables.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cur = tables[indexPath.row]
        let tableLoc = CLLocation(latitude: cur.latitude, longitude: cur.longitude)
        let distance = ViewController.myLocationVar.CLL.distance(from: tableLoc)/1609.344
        
        cell.textLabel?.text = cur.owner
        if selectedCells.contains(indexPath) {
            cell.detailTextLabel?.text = cur.contactInfo
        } else {
            cell.detailTextLabel?.text = String(format: "%.2f", distance)+" miles away"
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedCells.contains(indexPath) {
            guard let getIndex = selectedCells.firstIndex(of: indexPath) else { return  }
            selectedCells.remove(at: getIndex)
        }else{
            selectedCells.append(indexPath)
        }

        self.tableView.reloadData()
        
        let cur = tables[indexPath.row]
        
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.mapController) as? ViewController
        self.view.window?.rootViewController = mapViewController
        self.view.window?.makeKeyAndVisible()
        mapViewController?.goToLocation(latitude: cur.latitude, longitude: cur.longitude)
        
    }
    
    func selectCell(indexPath: IndexPath) {
        selectedCells.append(indexPath)
        self.tableView.reloadData()
    }
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        fetchTables(reload: false)
        self.tables = searchText.isEmpty ? tables : tables.filter({
            $0.owner.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        self.tableView.reloadData()
        
    }
    func fetchTables(reload: Bool=true) {
        let db = Firestore.firestore()
        db.collection("Tables").getDocuments { (snapchat, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapchat?.documents)! {
                    
                    let cur = document.data()
                    let id = cur["id"] as! String
                    let owner = cur["owner"] as! String
                    let contactInfo = cur["contactInfo"] as! String
                    let latitude = cur["latitude"] as! Double
                    let longitude = cur["longitude"] as! Double
                    if (!self.tables.contains(where: {$0.id == id})) {
                        self.tables.insert(tableStruct(id: id, owner: owner, contactInfo: contactInfo, latitude: latitude, longitude: longitude), at: 0)
                    }
                    if (reload) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
            
    }
}

