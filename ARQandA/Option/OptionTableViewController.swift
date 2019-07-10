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
    
    var bgm = AVAudioPlayer()
   
    @IBOutlet weak var btnBackToMenu: UIButton!
    var nameTextField: UITextField?

    let list = [["返回標題"],
                ["修改個人資料","清除資料"],
                ["教學導覽","分享給好友"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !bgm.isPlaying{
            bgm.play()
        }
        
        btnBackToMenu.bounds.size.width = 44
    }
    
    @IBAction func backToMenu(){
         performSegue(withIdentifier: "ReturnToMenu01", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let sendBgm = segue.destination as? MenuViewController{
            sendBgm.bgm = self.bgm
        }
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
            let backToTitle = storyboard?.instantiateViewController(withIdentifier: "Title") as! LaunchViewController
            backToTitle.bgm = self.bgm
            present(backToTitle, animated: true, completion: nil)
            /*
            if let backToTitle = storyboard?.instantiateViewController(withIdentifier: "Title"){
                present(backToTitle, animated: true, completion: nil)
            }*/
            break
        case 1:
            switch indexPath.row{
            case 0:
                let alertController = UIAlertController(title: "請輸入姓名", message: nil, preferredStyle: .alert)
                alertController.addTextField(configurationHandler: {
                    $0.placeholder = "Name"
                    $0.addTarget(alertController, action: #selector(alertController.textDidChangeInNameTextField), for: .editingChanged)
                })
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    guard let name = alertController.textFields?[0].text else{return}
                    UserDefaults.standard.set(name,forKey: "name")
                    UserDefaults.standard.synchronize()
                })
                
                okAction.isEnabled = false
                alertController.addAction(okAction)
                present(alertController, animated: true)
                break
            case 1:
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
            break
        case 2:
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
        
        
        UserDefaults.standard.synchronize()
        
        let backToTitle = storyboard?.instantiateViewController(withIdentifier: "Title") as! LaunchViewController
        backToTitle.bgm = self.bgm
        present(backToTitle, animated: true, completion: nil)
        /*
        if let backToTitle = storyboard?.instantiateViewController(withIdentifier: "Title"){
            present(backToTitle, animated: true, completion: nil)
        }
        */
    }
}
