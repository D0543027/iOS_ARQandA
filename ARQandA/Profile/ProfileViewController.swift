//
//  ProfileViewController.swift
//  ARQandA
//
//  Created by 李其准 on 2019/7/6.
//  Copyright © 2019年 蔣聖訢. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
    let profileTitle = ["名字：",
                   "開始遊玩日期：",
                   "遊玩天數：",
                   "回答總題數：",
                   "答對數：",
                   "答錯數：",
                   "準確率：",
                   "單次遊玩最高分： "]
    
    let profileData = [UserDefaults.standard.string(forKey: "name"),
                       UserDefaults.standard.string(forKey: "startDate"),
                       UserDefaults.standard.string(forKey: "playDate"),
                       UserDefaults.standard.string(forKey: "total"),
                       UserDefaults.standard.string(forKey: "right"),
                       UserDefaults.standard.string(forKey: "wrong"),
                       UserDefaults.standard.string(forKey: "correctPercentage"),
                       UserDefaults.standard.string(forKey: "highScore")]
    @IBOutlet weak var profile: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profile.delegate = self
        profile.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        cell.textLabel?.text = profileTitle[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        
        cell.detailTextLabel?.text = profileData[indexPath.row]
        cell.detailTextLabel?.textColor = UIColor.blue
        cell.detailTextLabel?.textAlignment = .right
        cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        return cell
    }
}
