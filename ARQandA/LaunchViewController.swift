//
//  LaunchView.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/6/19.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    @IBOutlet var background: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let fullScreenSize = UIScreen.main.bounds.size
        background = UIImageView(frame : CGRect(x:0, y:0, width: fullScreenSize.width, height: fullScreenSize.height))
        let imgArr = [UIImage(named:"background01")!,
                      UIImage(named:"background02")!,
                      UIImage(named:"background03")!,
                      UIImage(named:"background04")!,
                      UIImage(named:"background05")!,
                      UIImage(named:"background06")!,
                      UIImage(named:"background07")!,
                      UIImage(named:"background08")!,
                      UIImage(named:"background09")!,
                      UIImage(named:"background10")!,
                      UIImage(named:"background11")!,
                      UIImage(named:"background12")!,
                      UIImage(named:"background13")!,
                      UIImage(named:"background14")!,
                      UIImage(named:"background15")!,
                      UIImage(named:"background16")!,
                      UIImage(named:"background17")!,
                      UIImage(named:"background18")!,
                      UIImage(named:"background19")!,
                      UIImage(named:"background20")!,
                      UIImage(named:"background21")!,
                      UIImage(named:"background22")!,
                      UIImage(named:"background23")!,
                      UIImage(named:"background24")!,
                      UIImage(named:"background25")!,
                      UIImage(named:"background26")!,
                      UIImage(named:"background27")!,
                      UIImage(named:"background28")!,
                      UIImage(named:"background29")!,
                      UIImage(named:"background30")!,
                      UIImage(named:"background31")!,
                      UIImage(named:"background32")!,
                      UIImage(named:"background33")!,
                      UIImage(named:"background34")!,
                      UIImage(named:"background35")!,
                      UIImage(named:"background36")!,
                      UIImage(named:"background37")!,
                      UIImage(named:"background38")!,
                      UIImage(named:"background39")!,]
        background.animationImages = imgArr
        background.animationDuration = 1
        background.animationRepeatCount = 0
        background.startAnimating()
        self.view.addSubview(background)
        self.view.sendSubviewToBack(background)
        // Do any additional setup after loading the view.
        FirstLaunch()
        updatePlayDate()
        
    }
    
    // 第一次開啟APP，創建儲存空間，值為0
    func FirstLaunch(){
        if UserDefaults.standard.object(forKey: "name") == nil{
            UserDefaults.standard.set("NULL", forKey: "name")
            UserDefaults.standard.synchronize()
        }
        //記錄最高分數
        if UserDefaults.standard.object(forKey: "highScore") == nil{
            UserDefaults.standard.set(0, forKey: "highScore")
            UserDefaults.standard.synchronize()
        }
        //記錄總答錯數
        if UserDefaults.standard.object(forKey: "wrong") == nil{
            UserDefaults.standard.set(0, forKey: "wrong")
            UserDefaults.standard.synchronize()
        }
        //記錄總答對數
        if UserDefaults.standard.object(forKey: "right") == nil{
            UserDefaults.standard.set(0, forKey: "right")
            UserDefaults.standard.synchronize()
        }
        
        if UserDefaults.standard.object(forKey: "startDate") == nil{
            let currentDate = Date()
            let dataFormatter = DateFormatter()
            dataFormatter.locale = Locale(identifier: "zh_Hant_TW")
            dataFormatter.dateFormat = "YYYY-MM-dd"
            let stringDate = dataFormatter.string(from: currentDate)
            UserDefaults.standard.set(stringDate, forKey: "startDate")
            UserDefaults.standard.synchronize()
        }
        
        if UserDefaults.standard.object(forKey: "playDate") == nil{
            UserDefaults.standard.set(1, forKey: "playDate")
            UserDefaults.standard.synchronize()
        }
        
        if UserDefaults.standard.object(forKey: "currentDate") == nil{
            let currentDate = Date()
            let dataFormatter = DateFormatter()
            dataFormatter.locale = Locale(identifier: "zh_Hant_TW")
            dataFormatter.dateFormat = "YYYY-MM-dd"
            let stringDate = dataFormatter.string(from: currentDate)
            UserDefaults.standard.set(stringDate, forKey: "currentDate")
            UserDefaults.standard.synchronize()
        }
        
        if UserDefaults.standard.object(forKey: "total") == nil{
            UserDefaults.standard.set(0, forKey: "total")
            UserDefaults.standard.synchronize()
        }

        if UserDefaults.standard.object(forKey: "correctPercentage") == nil{
            UserDefaults.standard.set(0, forKey: "correctPercentage")
            UserDefaults.standard.synchronize()
        }
    }
    
    func updatePlayDate(){
        let today = Date()
        let dataFormatter = DateFormatter()
        dataFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dataFormatter.dateFormat = "YYYY-MM-dd"
        let currentDate = dataFormatter.string(from: today)
        
        let savedCurrentDate = UserDefaults.standard.string(forKey: "currentDate")
        var playDate = UserDefaults.standard.integer(forKey: "playDate")
 
        
        if currentDate != savedCurrentDate{
            playDate = playDate + 1
            UserDefaults.standard.set(playDate,forKey: "playDate")
            UserDefaults.standard.set(currentDate,forKey: "currentDate")
            UserDefaults.standard.synchronize()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBOutlet weak var aboutBtn: UIButton!
    @IBAction func about(_ sender: Any) {
        
    }
    
    @IBOutlet weak var startBtn: UIButton!
    @IBAction func start(_ sender: Any) {
        background.stopAnimating()
        performSegue(withIdentifier: "ToMenu", sender: sender)
    }
}
