//
//  OptionTableViewController.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/7/5.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import UIKit

class OptionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let list = ["我","不","知","教學導覽","分享給好友"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let t = list[indexPath.row]
        cell.textLabel?.text = "\(t) Section: \(indexPath.section) row: \(indexPath.row)"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Header"
        return label
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 3:
            if let tutorialController = storyboard?.instantiateViewController(withIdentifier: String(describing: TutorialViewController.self)) as? TutorialViewController{
                present(tutorialController, animated: true, completion: nil)
            }
            break
        case 4:
            let text = "J個很好玩"
            let image = UIImage(named: "LOGO.png")
            let sharedAll = [text,image!] as[ Any]
            let activityController = UIActivityViewController(activityItems: sharedAll, applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = self.view
            present(activityController, animated: true, completion: nil)
        default:
            break
        }
    }    
    
}
