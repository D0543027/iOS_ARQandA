//
//  OptionTableViewController.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/7/5.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import UIKit
import AVFoundation
class OptionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
   
    @IBOutlet weak var btnBackToMenu: UIButton!
    var nameTextField: UITextField?

    let list = [["返回標題", "BGM"],
                ["修改個人資料","清除資料"],
                ["教學導覽","分享給好友"]]
    
    var detailList = [["","ON"],
                      ["",""],
                      ["",""]]
    
    var BGM_status = UserDefaults.standard.float(forKey: "BGM")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBackToMenu.bounds.size.width = 44
        if BGM_status == 1.0{
            detailList[0][1] = "ON"
        }
        else{
            detailList[0][1] = "OFF"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = list[indexPath.section][indexPath.row]
        cell.detailTextLabel?.text = detailList[indexPath.section][indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
            switch indexPath.row{
            case 0:
                performSegue(withIdentifier: "backToLaunch", sender: self)
                break
            case 1:
                if BGM_status == 1.0{  // Switch BGM from on to off
                    BGM_status = 0.0
                    AudioManager.sharedInstance.switchBGM(volumn: BGM_status)
                    UserDefaults.standard.set(BGM_status, forKey: "BGM")
                    detailList[0][1] = "OFF"
                }
                else{ // Switch BGM from off to on
                    BGM_status = 1.0
                    UserDefaults.standard.set(BGM_status, forKey: "BGM")
                    AudioManager.sharedInstance.switchBGM(volumn: BGM_status)
                    detailList[0][1] = "ON"
                }
                tableView.reloadData()
                break;
            default:
                break;
            }
        }
        else if indexPath.section == 1{
            switch indexPath.row{
            case 0: //修改個人資料
                let alertController = UIAlertController(title: "請輸入姓名", message: nil, preferredStyle: .alert)
                alertController.addTextField(configurationHandler: {
                    $0.placeholder = "Name"
                    $0.addTarget(alertController, action: #selector(alertController.textDidChangeInNameTextField), for: .editingChanged)
                })
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    guard let name = alertController.textFields?[0].text else{return}
                    UserDefaults.standard.set(name,forKey: "name")
                })
                
                okAction.isEnabled = false
                alertController.addAction(okAction)
                present(alertController, animated: true)
                break
            case 1: //清除資料
                let alertController = UIAlertController(title: "確定要清除資料？", message: nil, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: self.clearProfile)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true)
                break
            default:
                break
            }
        }
        else if indexPath.section == 2{
            switch indexPath.row{
            case 0: //教學導覽
                if let tutorialController = storyboard?.instantiateViewController(withIdentifier: String(describing: TutorialViewController.self)) as? TutorialViewController{
                    present(tutorialController, animated: true, completion: nil)
                }
                break
            case 1: //分享給好友
                let text = "108學年度逢甲資訊系專題展\n組別：AR應用"
                let image = UIImage(named: "LOGO.png")
                let sharedAll = [text,image!] as[ Any]
                let activityController = UIActivityViewController(activityItems: sharedAll, applicationActivities: nil)
                activityController.popoverPresentationController?.sourceView = self.view
                present(activityController, animated: true, completion: nil)
                break
            default:
                break
            }
        }
    }
    
    func clearProfile(alert: UIAlertAction){
        UserDefaults.standard.set(" ", forKey: "name")
        UserDefaults.standard.set(0, forKey: "highScore")
        UserDefaults.standard.set(0, forKey: "wrong")
        UserDefaults.standard.set(0, forKey: "right")
        
        let currentDate = Date()
        let dataFormatter = DateFormatter()
        dataFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dataFormatter.dateFormat = "YYYY-MM-dd"
        let stringDate = dataFormatter.string(from: currentDate)
        UserDefaults.standard.set(stringDate, forKey: "startDate")
        UserDefaults.standard.set(stringDate, forKey: "currentDate")
        
        UserDefaults.standard.set(0, forKey: "total")
        UserDefaults.standard.set(0, forKey: "correctPercentage")
        UserDefaults.standard.set(1, forKey: "playDate")
        
        performSegue(withIdentifier: "backToLaunch", sender: self)
    }
}
