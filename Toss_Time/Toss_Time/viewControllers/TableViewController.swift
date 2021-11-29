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

// struct that follows Database row of tables
struct tableStruct {
    let id: String!
    let owner: String!
    let contactInfo: String!
    let latitude: Double!
    let longitude: Double!
}
/**
View cotroller class that:
 1. Displays available tables in a list form
 2. Distance from table to current location given
 3. On table click, ViewController brings to table location
 4. Timer to switch out contact info/location
 */
class TableViewController: UITableViewController, UISearchBarDelegate {
    
    var tables = [tableStruct]()
    @IBOutlet weak var searchBar: UISearchBar!
    var toggleInfo = true
    var timer: Timer?
    /**
    Function initializes table, fetches data from database, starts timer
     - Parameters: None
     - Returns:    None
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        // fetch data from database into tables var
        fetchTables()
        // set up timer
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.toggleData), userInfo: nil, repeats: true)
    }
    /**
    Function switches boolean and reloads table cells (to choose which cell to display)
     - Parameters: None
     - Returns:    None
     */
    @objc func toggleData()
    {
        // switch content and reload
        self.toggleInfo = !self.toggleInfo
        self.tableView.reloadData()
    }
    /**
    Function stops timer switching data and sets to location showing only
     - Parameters: None
     - Returns:    None
     */
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
        toggleInfo = false
    }
     /**
    Function returns number of sections per row, only 1 needed
     - Parameters:
        - tableView       UITableView of View Controller
     - Returns:
        number of sections per row
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    /**
    Function returns number of rows in section, hence list length
     - Parameters:
        - tableView       UITableView of View Controller
        - section number of rows in section hence list length*1
     - Returns:
        number of table rows
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tables.count
    }
    /**
    Function loads data into table cell at indexPath
     - Parameters:
        - tableView       UITableView of View Controller
        - indexPath     row of cell to which to set content at
     - Returns:
        cell at row number indexPath
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get unused cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // retrieve table at row indexPath
        let cur = tables[indexPath.row]
        // get table location
        let tableLoc = CLLocation(latitude: cur.latitude, longitude: cur.longitude)
        // calculate distance between current location and table in miles
        let distance = ViewController.myLocationVar.CLL.distance(from: tableLoc)/1609.344
        // set table owner name
        cell.textLabel?.text = cur.owner
        // switch between Contact Info and Distance From Table
        if (toggleInfo) {
            cell.detailTextLabel?.text = cur.contactInfo
        } else {
            cell.detailTextLabel?.text = String(format: "%.2f", distance)+" miles away"
        }
        return cell
    }
    /**
    Function brings user to clicked table's location
     - Parameters:
        - tableView       UITableView of View Controller
        - indexPath       row of cell that was selected or clicked
     - Returns:       None
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get table at indexPath from local var
        let cur = tables[indexPath.row]
        // initiate ViewController (Google Maps)
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.mapController) as? ViewController
        self.view.window?.rootViewController = mapViewController
        // preset table coordinates to be shown on ViewController
        mapViewController?.goToLocation(latitude: cur.latitude, longitude: cur.longitude)
        // present viewController
        self.view.window?.makeKeyAndVisible()
        
    }
    /**
    Function returns tables where Table Owners contains searchText
     - Parameters:
        - searchBar       UISearchBar that reacts on change, linked to storyboard
        - searchText     if user types into searchbar, reload function and searchText = typed text
     - Returns:       None
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        stopTimer()
        // reload tables into self.tables without reloading data
        fetchTables(reload: false)
        // filter data case insensitive to search for table owners
        self.tables = searchText.isEmpty ? tables : tables.filter({
            $0.owner.range(of: searchText, options: .caseInsensitive) != nil
        })
        // reload table cells
        self.tableView.reloadData()
        
    }
    /**
    Function returns number of sections per row, only 1 needed
     - Parameters:
        - reload     boolean that decides if table reloads data upon inserting database entries into local array
     - Returns:       None
     */
    func fetchTables(reload: Bool=true) {
        let db = Firestore.firestore()
        // retrieve table data
        db.collection("Tables").getDocuments { (snapchat, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapchat?.documents)! {
                    // get all fields of table
                    let cur = document.data()
                    let id = cur["id"] as! String
                    let owner = cur["owner"] as! String
                    let contactInfo = cur["contactInfo"] as! String
                    let latitude = cur["latitude"] as! Double
                    let longitude = cur["longitude"] as! Double
                    // if table already in list, continue
                    if (!self.tables.contains(where: {$0.id == id})) {
                        // insert into tableStruct format
                        self.tables.insert(tableStruct(id: id, owner: owner, contactInfo: contactInfo, latitude: latitude, longitude: longitude), at: 0)
                    }
                    // if true reload table cell data
                    if (reload) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
            
    }
}

