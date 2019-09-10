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
    var score = 0.0             // 單次分數
    var singleRight = 0         // 單次答對數
    var singleWrong = 0         // 單次打錯數
    var label = ""              // 物件名稱
    var difficulty = ""         // 難易度
    var magnification = 1.0     // 倍率
    var point = 5.0             // 答對單題分數
    var data: JSON?
    var audioPlayerF = AVAudioPlayer()
    var audioPlayerV = AVAudioPlayer()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let semaphore = DispatchSemaphore(value: 0)
    var timer: Timer?
    
    let secondsDict = ["Easy": 10, "Normal": 5, "Hard" : 3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //讓文字換行，避免文字太常產生省略情形(abc...xyz這樣)
        print(difficulty)
        
        questionLabel.numberOfLines = 0
        
        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "giphy.gif"))
        setUpResultScene()
        setUpVictoryFailed()
        setUpValidChoice()
        setUpChoiceButton()
        setUpActivityIndicator()
        
        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        semaphore.wait()
        
        //抓完資料，轉圈停止
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents() //可觸發任何元件(按鈕......等)
        
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

    fileprivate func setUpResultScene() {
        //隱藏結算畫面物件
        resultBackground.isHidden = true
        resultBack.isHidden = true
        singleScoreValue.isHidden = true
        singleRightValue.isHidden = true
        singleWrongValue.isHidden = true
        singleHighScoreValue.isHidden = true
        singleScoreLabel.isHidden = true
        singleRightLabel.isHidden = true
        singleWrongLabel.isHidden = true
        singleHighScoreLabel.isHidden = true
    }
    
    fileprivate func setUpValidChoice() {
        validFirstChoice.isHidden = true
        validSecondChoice.isHidden = true
        validThirdChoice.isHidden = true
        validFourthChoice.isHidden = true
    }
    
    fileprivate func setUpVictoryFailed() {
        //隱藏victory和failed圖示
        victoryFailed_pic.isHidden = true
    }
    
    fileprivate func setUpChoiceButton(){
        firstChoice.tag = 1
        secondChoice.tag = 2
        thirdChoice.tag = 3
        fourthChoice.tag = 4
        
        firstChoice.titleLabel?.numberOfLines = 0
        secondChoice.titleLabel?.numberOfLines = 0
        thirdChoice.titleLabel?.numberOfLines = 0
        fourthChoice.titleLabel?.numberOfLines = 0
    }
    
    fileprivate func setUpActivityIndicator() {
        // 讀取中，轉圈
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .whiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func getData(){
        let queue = DispatchQueue(label: "queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem)
        // parameters： 參數對應 query.php 的 _POST
        let parameters = ["tablename": "plant_questions", "num": "5"]
        print("Selected label: \(label)")
        
        Alamofire.request("http:/172.20.10.7:8080/query.php", method: .post, parameters: parameters).responseJSON(queue:queue, completionHandler:{ response in
            if response.result.isSuccess{
                if let value = response.result.value{
                    let json = JSON(value)
                    self.data = json
                    self.semaphore.signal()
                }
            }
        })
    }
    
    
    private var index = 0
    private var RightAnswer: String? = ""
    
    @IBOutlet weak var resultBackground: UIImageView!
    @IBOutlet weak var resultBack: UIImageView!
    @IBOutlet weak var singleScoreValue: UILabel!
    @IBOutlet weak var singleRightValue: UILabel!
    @IBOutlet weak var singleWrongValue: UILabel!
    @IBOutlet weak var singleHighScoreValue: UILabel!
    @IBOutlet weak var singleScoreLabel: UILabel!
    @IBOutlet weak var singleRightLabel: UILabel!
    @IBOutlet weak var singleWrongLabel: UILabel!
    @IBOutlet weak var singleHighScoreLabel: UILabel!
    
    fileprivate func showResultScene() {
        resultBackground.isHidden = false
        resultBack.isHidden = false
        singleScoreValue.isHidden = false
        singleRightValue.isHidden = false
        singleWrongValue.isHidden = false
        singleHighScoreValue.isHidden = false
        singleScoreLabel.isHidden = false
        singleRightLabel.isHidden = false
        singleWrongLabel.isHidden = false
        singleHighScoreLabel.isHidden = false
    }
    
    func updateQuestion(){
        // 答完題目
        if index == data!.count{
            // 答題結束畫面
            timer?.invalidate()
            
            questionLabel.text = ""
            firstChoice.setTitle("", for: .normal)
            secondChoice.setTitle("", for: .normal)
            thirdChoice.setTitle("", for: .normal)
            fourthChoice.setTitle("", for: .normal)
            
            showResultScene()
            
            if score < 0{
                score = 0
            }
            
            var highScore = UserDefaults.standard.double(forKey: "highScore")
            //更新最高分數
            if highScore < score {
                highScore = score
                UserDefaults.standard.set(String(format: "%.2f",highScore), forKey: "highScore")
            }
            
            var rightCount = UserDefaults.standard.integer(forKey: "right")
            rightCount = rightCount + singleRight
            UserDefaults.standard.set(rightCount, forKey: "right")
            
            var wrongCount = UserDefaults.standard.integer(forKey: "wrong")
            wrongCount = wrongCount + singleWrong
            UserDefaults.standard.set(wrongCount, forKey: "wrong")
            
            UserDefaults.standard.set(rightCount + wrongCount , forKey: "total")
            
            singleScoreValue.text = String(format: "%.2f", score)
            singleRightValue.text = String(singleRight)
            singleWrongValue.text = String(singleWrong)
            singleHighScoreValue.text = String(format: "%.2f",highScore)
            
            calculatePercentage()
            // 設延遲(5 sec)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5) , execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        else {
            enableChoiceButton()
            questionLabel.text = self.data![index]["Question"].string
            
            RightAnswer = self.data![index]["Ans"].string
            
            // 預設：第二個選項是解答
            firstChoice.setTitle(self.data![index]["choose1"].string, for: .normal)
            secondChoice.setTitle(self.data![index]["Ans"].string, for: .normal)
            thirdChoice.setTitle(self.data![index]["choose3"].string, for: .normal)
            fourthChoice.setTitle(self.data![index]["choose4"].string, for: .normal)
            
            // 如果只有三個選項，第四個選項不能選
            if fourthChoice.currentTitle == ""{
                fourthChoice.isEnabled = false
            }
            // 打亂順序
            shuffleChoice()
            index = index + 1
            let timeLimit = secondsDict[difficulty]
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeLimit!), repeats: false) { (_) in
                self.showAnswer()
                self.disableChoiceButton()
                self.victoryFailed_pic.image = UIImage(named: "timeout.png")
                self.victoryFailed_pic.isHidden = false
                self.singleWrong = self.singleWrong + 1
                self.point = 5
                print("Timeout...")
                print(self.score)
                print(self.point)
                self.timer?.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) , execute: {
                    self.hideVictoryFailed()
                    self.hideValidSign()
                    self.updateQuestion()
                })
                
            }
            
        }
    }
    
    //打亂順序
    func shuffleChoice(){
        let choiceArray = [firstChoice,secondChoice,thirdChoice,fourthChoice]
        for _ in 0...50{
            let rand = Int.random(in: 0...3)
            let selectString = choiceArray[rand]?.currentTitle
            if selectString?.isEmpty != true{
                let temp = choiceArray[0]?.currentTitle
                choiceArray[0]?.setTitle(selectString, for: .normal)
                choiceArray[rand]?.setTitle(temp, for: .normal)
            }
        }
    }
    
    func validAnswer(button: UIButton){
        
        let validSign = [validFirstChoice, validSecondChoice, validThirdChoice, validFourthChoice]
        let selectButton = button.tag - 1 // 選項tag分別為1,2,3,4
        
        if RightAnswer == button.currentTitle{
            BtnVictory()
            validSign[selectButton]!.image = UIImage(named: "checksign.jpg") //顯示所選的選項對錯
            
            score = score + point
            point = point * 1.5
            print("Right...")
            print(point)
            print(score)

            singleRight = singleRight + 1
        } else {
            BtnFailed()
            validSign[selectButton]!.image = UIImage(named: "wrongsign.jpeg") //顯示所選的選項對錯
            
            point = 5
            print("Wrong...")
            print(point)
            print(score)
 
            singleWrong = singleWrong + 1
        }
        validSign[selectButton]?.isHidden = false
    }
    
    func showAnswer(){
        let choices = [firstChoice,secondChoice,thirdChoice,fourthChoice]
        let checkSign = [validFirstChoice, validSecondChoice, validThirdChoice, validFourthChoice]
        var tag = 0
        for btn in choices{
            if RightAnswer == btn?.currentTitle{
                tag = (btn?.tag)! //答案之選項tag
                break
            }
        }
        tag = tag - 1 //選項tag分別為1,2,3,4，故這裡要減1
        checkSign[tag]?.image = UIImage(named: "checksign.jpg")
        checkSign[tag]?.isHidden = false
        
    }
    func calculatePercentage(){
        let rightCount = UserDefaults.standard.integer(forKey: "right")
        let total = UserDefaults.standard.integer(forKey: "total")
        print(rightCount)
        print(total)
        let percentage = (Double(rightCount) / Double(total) ) * 100
        let strPercentage = "\(String(format: "%.2f", percentage)) %"
        print(strPercentage)
        UserDefaults.standard.set(strPercentage, forKey: "correctPercentage")

    }

    func BtnVictory() {
        audioPlayerV.play()
        victoryFailed_pic.image = UIImage(named: "Victory.png")
        victoryFailed_pic.isHidden = false
    }
    
    func BtnFailed() {
        audioPlayerF.play()
        victoryFailed_pic.image = UIImage(named: "Failed.png")
        victoryFailed_pic.isHidden = false
    }
    
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var victoryFailed_pic: UIImageView!
    @IBOutlet weak var firstChoice: UIButton!
    @IBOutlet weak var validFirstChoice: UIImageView!
    @IBAction func firstChocieTapped(_ sender: Any) {
        choicesButtonAction(button: firstChoice)
    }
    
    @IBOutlet weak var secondChoice: UIButton!
    @IBOutlet weak var validSecondChoice: UIImageView!
    @IBAction func secondChoiceTapped(_ sender: Any) {
        choicesButtonAction(button: secondChoice)
    }
    
    @IBOutlet weak var thirdChoice: UIButton!
    @IBOutlet weak var validThirdChoice: UIImageView!
    @IBAction func thirdChoiceTapped(_ sender: Any) {
        choicesButtonAction(button: thirdChoice)
    }
    
    @IBOutlet weak var fourthChoice: UIButton!
    @IBOutlet weak var validFourthChoice: UIImageView!
    @IBAction func fourthChoiceTapped(_ sender: Any) {
        choicesButtonAction(button: fourthChoice)
    }
    
    func choicesButtonAction(button: UIButton){
        disableChoiceButton()
        timer?.invalidate()
        validAnswer(button: button)
        showAnswer()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) , execute: {
            self.hideVictoryFailed()
            self.hideValidSign()
            self.updateQuestion()
        })
    }
    
    func enableChoiceButton(){
        firstChoice.isEnabled = true
        secondChoice.isEnabled = true
        thirdChoice.isEnabled = true
        fourthChoice.isEnabled = true
    }
    
    func disableChoiceButton(){
        firstChoice.isEnabled = false
        secondChoice.isEnabled = false
        thirdChoice.isEnabled = false
        fourthChoice.isEnabled = false
    }
    
    func hideValidSign(){
        validFirstChoice.isHidden = true
        validSecondChoice.isHidden = true
        validThirdChoice.isHidden = true
        validFourthChoice.isHidden = true
    }
    
    func hideVictoryFailed(){
        victoryFailed_pic.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
