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
    
    var label = ""              // 物件名稱
    var numberOfQuestion = ""   // 題數
    
    var data: JSON?
    
    var audioPlayerF = AVAudioPlayer();
    var audioPlayerV = AVAudioPlayer();
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "giphy.gif"))
        
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
        
        
        Alamofire.request("https://4061f669.ngrok.io/query.php", method: .post, parameters: parameters).responseJSON(queue:queue, completionHandler:{ response in
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
    func updateQuestion(){
        
        // 答完題目
        if index == data!.count{
            print("Finish")
            // 答題結束畫面
            lb.text = "Finish"
            ChoiceBtnLabel1.setTitle("Finish", for: .normal)
            ChoiceBtnLabel2.setTitle("Finish", for: .normal)
            ChoiceBtnLabel3.setTitle("Finish", for: .normal)
            ChoiceBtnLabel4.setTitle("Finish", for: .normal)
            
            // 答完題 不得觸發選項(點選項不動作）
            ChoiceBtnLabel1.isEnabled = false
            ChoiceBtnLabel2.isEnabled = false
            ChoiceBtnLabel3.isEnabled = false
            ChoiceBtnLabel4.isEnabled = false
            // 設延遲(2 sec)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2) , execute: {
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
        
        if RightAnswer == button.currentTitle{
            BtnVictory()
            
            //答對分數++
            let score = UserDefaults.standard.integer(forKey: "score")
            UserDefaults.standard.set(score + 1, forKey: "score")
            UserDefaults.standard.synchronize() //這行一定要加，不然不會存回去
        } else {
            BtnFailed()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func BtnVictory() {
        audioPlayerV.play()
        victory.isUserInteractionEnabled = true
    }
    func BtnFailed() {
        audioPlayerF.play();
        failed.isUserInteractionEnabled = true

    }
    
    
    @IBOutlet weak var lb: UILabel!
    @IBOutlet weak var victory: UIImageView!
    @IBOutlet weak var failed: UIImageView!
    
    @IBOutlet weak var ChoiceBtnLabel1: UIButton!
    @IBAction func ChoiceBtn1(_ sender: Any) {
        validAnswer(button: ChoiceBtnLabel1)
        updateQuestion()
    }
    
    @IBOutlet weak var ChoiceBtnLabel2: UIButton!
    @IBAction func ChoiceBtn2(_ sender: Any) {
        validAnswer(button: ChoiceBtnLabel2)
        updateQuestion()
    }
    
    @IBOutlet weak var ChoiceBtnLabel3: UIButton!
    @IBAction func ChoiceBtn3(_ sender: Any) {
        validAnswer(button: ChoiceBtnLabel3)
        updateQuestion()
    }
    
    @IBOutlet weak var ChoiceBtnLabel4: UIButton!
    @IBAction func ChoiceBtn4(_ sender: Any) {
        validAnswer(button: ChoiceBtnLabel4)
        updateQuestion()
    }
    
    
}
