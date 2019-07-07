//
//  ProfileViewController.swift
//  ARQandA
//
//  Created by 李其准 on 2019/7/6.
//  Copyright © 2019年 蔣聖訢. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController ,UITableViewDataSource{
    let right = UserDefaults.standard.integer(forKey: "right")
    let wrong = UserDefaults.standard.integer(forKey: "wrong")
    var list = ["",
                "",
                String(0),
                String(right + wrong),
                String(right),
                String(wrong),
                String(Int(right/(right + wrong))),
                String(UserDefaults.standard.integer(forKey: "highScore"))]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "name", for: indexPath) as? ProfileTableViewCell else {
            return UITableViewCell()
        }
        cell.nameLb.text = list[0]
        cell.beginDateLb.text = list[1]
        cell.dayCountLb.text = list[2]
        cell.totalLb.text = list[3]
        cell.rightLb.text = list[4]
        cell.wrongLb.text = list[5]
        cell.accuracyLb.text = list[6]
        cell.onceHScoreLb.text = list[7]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
/*
    func tableView1(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ProfileTableViewCell {
        let cell = ProfileTableViewCell(style: .default, reuseIdentifier: "name")
        cell.nameLb.text = statusName
        return cell
    }
    func tableView2(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ProfileTableViewCell {
        let cell = ProfileTableViewCell(style: .default, reuseIdentifier: "beginDate")
        cell.beginDateLb.text = statusDate
        return cell
    }
    func tableView3(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ProfileTableViewCell {
        let cell = ProfileTableViewCell(style: .default, reuseIdentifier: "dayCount")
        cell.dayCountLb.text = String(statusList[0])
        return cell
    }
    func tableView4(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ProfileTableViewCell {
        let cell = ProfileTableViewCell(style: .default, reuseIdentifier: "total")
        cell.totalLb.text = String(statusList[1])
        return cell
    }
    func tableView5(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ProfileTableViewCell {
        let cell = ProfileTableViewCell(style: .default, reuseIdentifier: "right")
        cell.rightLb.text = String(statusList[2])
        return cell
    }
    func tableView6(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ProfileTableViewCell {
        let cell = ProfileTableViewCell(style: .default, reuseIdentifier: "wrong")
        cell.wrongLb.text = String(statusList[3])
        return cell
    }
    
    func tableView7(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ProfileTableViewCell {
        let cell = ProfileTableViewCell(style: .default, reuseIdentifier: "accuracy")
        cell.accuracyLb.text = String(statusList[4])
        return cell
    }
    
    func tableView8(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ProfileTableViewCell {
        let cell = ProfileTableViewCell(style: .default, reuseIdentifier: "onceHScore")
        cell.onceHScoreLb.text = String(statusList[5])
        return cell
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
