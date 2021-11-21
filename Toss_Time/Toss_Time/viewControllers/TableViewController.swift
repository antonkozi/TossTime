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

struct tableStruct {
    let owner: String!
    let contactInfo: String!
}

class TableViewController: UITableViewController {
    
    var tables = [tableStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        print("uitableview open")
        let db = Firestore.firestore()
        db.collection("Tables").getDocuments { (snapchat, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapchat?.documents)! {
                    
                    let cur = document.data()
                    let owner = cur["owner"] as! String
                    let contactInfo = cur["contactInfo"] as! String
                    
                    self.tables.insert(tableStruct(owner: owner, contactInfo: contactInfo), at: 0)
                    self.tableView .reloadData()
                }
            }
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        cell.textLabel?.text = tables[indexPath.row].owner
        cell.detailTextLabel?.text = tables[indexPath.row].contactInfo
        //print(tables[indexPath.row].houseRules)
       /* // Configure the cell...
        let label1 = cell.viewWithTag(1) as! UILabel
        label1.text = tables[indexPath.row].houseRules
        
        let label2 = cell.viewWithTag(2) as! UILabel
        label2.text = tables[indexPath.row].contactInfo
*/
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
