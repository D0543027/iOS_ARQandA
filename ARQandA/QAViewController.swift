//
//  ViewTwo.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/6/14.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//


import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON

class QAViewController: UIViewController {
    var score = 0               // 單次分數
    var singleRight = 0         // 單次答對數
    var singleWrong = 0         // 單次打錯數
    var label = ""              // 物件名稱
    var numberOfQuestion = ""   // 題數
    
    var data: JSON?
    var audioPlayerF = AVAudioPlayer()
    var audioPlayerV = AVAudioPlayer()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "giphy.gif"))
        //隱藏結算畫面物件
        resultBackground.isHidden = true
        resultBack.isHidden = true
        singleScoreLb.isHidden = true
        singleRightLb.isHidden = true
        singleWrongLb.isHidden = true
        singleHighScoreLb.isHidden = true
        singleScoreLbT.isHidden = true
        singleRightLbT.isHidden = true
        singleWrongLbT.isHidden = true
        singleHighScoreLbT.isHidden = true
        //隱藏victory和failed圖示
        victory.isHidden = true
        failed.isHidden = true
        
        // 讀取中，轉圈
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .whiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents() //不觸發任何元件
        
        getData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        //還在抓資料，迴圈卡在這
        while data == nil{}
        
        //抓完資料，轉圈停止
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents() //可觸發任何元件(按鈕......等)
        
        //print(data!)
        
        updateQuestion()
        
        do{
            let VS = URL(fileURLWithPath: Bundle.main.path(forResource:"VictorySound", ofType:"mp3")!)
            audioPlayerV = try AVAudioPlayer(contentsOf:VS)
            let FS = URL(fileURLWithPath: Bundle.main.path(forResource:"FailedSound", ofType:"mp3")!)
            audioPlayerF = try AVAudioPlayer(contentsOf:FS)
        }catch{
            
        }
        audioPlayerV.prepareToPlay()
        audioPlayerF.prepareToPlay()
        
    }
    
    
    func getData(){
        let queue = DispatchQueue(label: "queue")
        // parameters： 參數對應 query.php 的 _POST
        let parameters = ["label": self.label, "num": self.numberOfQuestion]
        
        
        Alamofire.request("https://7f1e37d5.ngrok.io/query.php", method: .post, parameters: parameters).responseJSON(queue:queue, completionHandler:{ response in
            if response.result.isSuccess{
                if let value = response.result.value{
                    let json = JSON(value)
                    self.data = json
                }
            }
        })
    }
    
    
    private var index = 0
    private var RightAnswer: String? = ""
    
    @IBOutlet weak var resultBackground: UIImageView!
    @IBOutlet weak var resultBack: UIImageView!
    @IBOutlet weak var singleScoreLb: UILabel!
    @IBOutlet weak var singleRightLb: UILabel!
    @IBOutlet weak var singleWrongLb: UILabel!
    @IBOutlet weak var singleHighScoreLb: UILabel!
    @IBOutlet weak var singleScoreLbT: UILabel!
    @IBOutlet weak var singleRightLbT: UILabel!
    @IBOutlet weak var singleWrongLbT: UILabel!
    @IBOutlet weak var singleHighScoreLbT: UILabel!
    
    func updateQuestion(){
        
        enableChoiceButton()
        
        // 答完題目
        if index == data!.count{
            // 答題結束畫面
            lb.text = ""
            ChoiceBtnLabel1.setTitle("", for: .normal)
            ChoiceBtnLabel2.setTitle("", for: .normal)
            ChoiceBtnLabel3.setTitle("", for: .normal)
            ChoiceBtnLabel4.setTitle("", for: .normal)
            
            resultBackground.isHidden = false
            resultBack.isHidden = false
            singleScoreLb.isHidden = false
            singleRightLb.isHidden = false
            singleWrongLb.isHidden = false
            singleHighScoreLb.isHidden = false
            singleScoreLbT.isHidden = false
            singleRightLbT.isHidden = false
            singleWrongLbT.isHidden = false
            singleHighScoreLbT.isHidden = false
            
            if score < 0{
                score = 0
            }
            
            var highScore = UserDefaults.standard.integer(forKey: "highScore")
            //更新最高分數
            if highScore < score {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "highScore")
            }
            
            singleScoreLb.text = String(score)
            singleRightLb.text = String(singleRight)
            singleWrongLb.text = String(singleWrong)
            singleHighScoreLb.text = UserDefaults.standard.string(forKey: "highScore")
            // 答完題 不得觸發選項(點選項不動作）


            
            calculatePercentage()
            // 設延遲(5 sec)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5) , execute: {
                self.dismiss(animated: true, completion: nil)
            })
            
        }
        else {
            
            lb.text = self.data![index]["Question"].string
            
            RightAnswer = self.data![index]["Ans"].string
            
            // 預設：第二個選項是解答
            ChoiceBtnLabel1.setTitle(self.data![index]["choose1"].string, for: .normal)
            ChoiceBtnLabel2.setTitle(self.data![index]["Ans"].string, for: .normal)
            ChoiceBtnLabel3.setTitle(self.data![index]["choose3"].string, for: .normal)
            ChoiceBtnLabel4.setTitle(self.data![index]["choose4"].string, for: .normal)
            index = index + 1
        }
    }

    func validAnswer(button: UIButton){
        
        let total = UserDefaults.standard.integer(forKey: "total")
        
        if RightAnswer == button.currentTitle{
            BtnVictory()
            //答對分數++（答對一題＋5分）
            score = score + 5
            //總答對數++
            let rightCount = UserDefaults.standard.integer(forKey: "right")
            UserDefaults.standard.set(rightCount + 1, forKey: "right")
            
            singleRight = singleRight + 1
        } else {
            BtnFailed()
            //答錯一題-3分
            score = score - 3
            //總答錯數++
            let countWrong = UserDefaults.standard.integer(forKey: "wrong")
            UserDefaults.standard.set(countWrong + 1, forKey: "wrong")
            
            singleWrong = singleWrong + 1
        }
        
        UserDefaults.standard.set(total + 1, forKey: "total")

    }
    
    func calculatePercentage(){
        let rightCount = UserDefaults.standard.integer(forKey: "right")
        let total = UserDefaults.standard.integer(forKey: "total")
        
        let percentage = (Double(rightCount) / Double(total) ) * 100
        let strPercentage = "\(String(format: "%.2f", percentage)) %"
        UserDefaults.standard.set(strPercentage, forKey: "correctPercentage")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func BtnVictory() {
        audioPlayerV.play()
        victory.isHidden = false
    }
    
    func BtnFailed() {
        audioPlayerF.play();
        failed.isHidden = false
 
    }
    
    
    @IBOutlet weak var lb: UILabel!
    @IBOutlet weak var victory: UIImageView!
    @IBOutlet weak var failed: UIImageView!
    @IBOutlet weak var ChoiceBtnLabel1: UIButton!
    @IBAction func ChoiceBtn1(_ sender: Any) {
        validAnswer(button: ChoiceBtnLabel1)
        disableChoiceButton()
        //延遲1秒
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) , execute: {
            self.victory.isHidden = true
            self.failed.isHidden = true
            
            self.updateQuestion()
        })
    }
    
    @IBOutlet weak var ChoiceBtnLabel2: UIButton!
    @IBAction func ChoiceBtn2(_ sender: Any) {
        validAnswer(button: ChoiceBtnLabel2)
        disableChoiceButton()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) , execute: {
            self.victory.isHidden = true
            self.failed.isHidden = true
            
            self.updateQuestion()
        })
    }
    
    @IBOutlet weak var ChoiceBtnLabel3: UIButton!
    @IBAction func ChoiceBtn3(_ sender: Any) {
        validAnswer(button: ChoiceBtnLabel3)
        disableChoiceButton()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) , execute: {
            self.victory.isHidden = true
            self.failed.isHidden = true
            
            self.updateQuestion()
        })
    }
    
    @IBOutlet weak var ChoiceBtnLabel4: UIButton!
    @IBAction func ChoiceBtn4(_ sender: Any) {
        validAnswer(button: ChoiceBtnLabel4)
        disableChoiceButton()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) , execute: {
            self.victory.isHidden = true
            self.failed.isHidden = true
            
            self.updateQuestion()
        })
    }
    
    func enableChoiceButton(){
        ChoiceBtnLabel1.isEnabled = true
        ChoiceBtnLabel2.isEnabled = true
        ChoiceBtnLabel3.isEnabled = true
        ChoiceBtnLabel4.isEnabled = true
    }
    
    func disableChoiceButton(){
        ChoiceBtnLabel1.isEnabled = false
        ChoiceBtnLabel2.isEnabled = false
        ChoiceBtnLabel3.isEnabled = false
        ChoiceBtnLabel4.isEnabled = false
    }
    
}
