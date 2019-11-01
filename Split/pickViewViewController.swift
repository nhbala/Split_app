//
//  pickViewViewController.swift
//  Split
//
//  Created by Nathan Bala on 10/30/19.
//  Copyright © 2019 Nathan Bala. All rights reserved.
//

import UIKit

class pickViewViewController: UITableViewController {
    
  
    var finalValues = [Item]()
    var taxVal = Item(itemName: "Empty", itemPrice: 0.0, itemAmount: 1, itemShared: true)
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        finalValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shareCell", for: indexPath)
        cell.textLabel?.text = finalValues[indexPath.row].itemName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark{
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
    }
    
    
    override func viewDidLoad() {
        print("hell11111o")
        
    }
        
        

        // Do any additional setup after loading the view.

    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
