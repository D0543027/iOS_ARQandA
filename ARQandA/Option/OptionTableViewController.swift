//
//  OptionTableViewController.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/7/5.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import UIKit

class OptionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
   
    @IBOutlet weak var btnBackToMenu: UIButton!
    
    let list = [["返回標題"],
                ["不"],
                ["知"],
                ["教學導覽","分享給好友"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBackToMenu.bounds.size.width = 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = list[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "123"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            if let backToTitle = storyboard?.instantiateViewController(withIdentifier: "Title"){
                present(backToTitle, animated: true, completion: nil)
            }
            break
        case 1:
            break
        case 2:
            break
        case 3:
            switch indexPath.row{
            case 0:
                if let tutorialController = storyboard?.instantiateViewController(withIdentifier: String(describing: TutorialViewController.self)) as? TutorialViewController{
                    present(tutorialController, animated: true, completion: nil)
                }
                break
            case 1:
                let text = "J個很好玩"
                let image = UIImage(named: "LOGO.png")
                let sharedAll = [text,image!] as[ Any]
                let activityController = UIActivityViewController(activityItems: sharedAll, applicationActivities: nil)
                activityController.popoverPresentationController?.sourceView = self.view
                present(activityController, animated: true, completion: nil)
                break
            default:
                break
            }
        default:
            break
        }
    }    
    
}
