//
//  OptionTableViewController.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/7/5.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import UIKit

class OptionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let list = ["我","不","知","教學導覽","道"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3{
            performSegue(withIdentifier: "Tutorial", sender: self)
        }
    }
    
    
}
