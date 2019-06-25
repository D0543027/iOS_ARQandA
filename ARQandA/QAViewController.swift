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
    
    var label = ""
    var number = ""
    
    
    var n = 0
    var data: JSON?
    var RightAnswer: String? = ""
    var audioPlayerF = AVAudioPlayer();
    var audioPlayerV = AVAudioPlayer();
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "giphy.gif"))
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .whiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        print(label)
        print(number)
        getData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        while data == nil{}
        
 
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
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
        let param = ["label":self.label, "num":self.number]
        Alamofire.request("https://8752d019.ngrok.io/query.php", method: .post, parameters: param).responseJSON(queue:queue, completionHandler:{ response in
            if response.result.isSuccess{
                if let value = response.result.value{
                    let json = JSON(value)
                    self.data = json
                }
            }
        })
    }
    
    func updateQuestion(){
        lb.text = self.data![n]["Question"].string
        
        RightAnswer = self.data![n]["Ans"].string
        ChoiseBtnLabel1.setTitle(self.data![n]["choose1"].string, for: .normal)
        ChoiseBtnLabel2.setTitle(self.data![n]["Ans"].string, for: .normal)
        ChoiseBtnLabel3.setTitle(self.data![n]["choose3"].string, for: .normal)
        ChoiseBtnLabel4.setTitle(self.data![n]["choose4"].string, for: .normal)
        
        
        n = n + 1
        
        if n == data!.count + 1{
            dismiss(animated: true, completion: nil)
        }
    }
    
    func validAnswer(button: UIButton){
        
        if RightAnswer == button.currentTitle{
            BtnVictory()
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
        victory.textColor = UIColor.yellow
        victory.text = "Victory"
    }
    func BtnFailed() {
        audioPlayerF.play();
        victory.textColor = UIColor.red
        victory.text = "Failed"
    }
    
    
    @IBOutlet weak var lb: UILabel!
    @IBOutlet weak var victory: UILabel!
    
    
    @IBOutlet weak var ChoiseBtnLabel1: UIButton!
    @IBAction func ChoiseBtn1(_ sender: Any) {
        validAnswer(button: ChoiseBtnLabel1)
        updateQuestion()
    }
    
    
    @IBOutlet weak var ChoiseBtnLabel2: UIButton!
    @IBAction func ChoiseBtn2(_ sender: Any) {
        validAnswer(button: ChoiseBtnLabel2)
        updateQuestion()
    }
    

    @IBOutlet weak var ChoiseBtnLabel3: UIButton!
    @IBAction func ChoiseBtn3(_ sender: Any) {
        validAnswer(button: ChoiseBtnLabel3)
        updateQuestion()
    }
    
    
    
    @IBOutlet weak var ChoiseBtnLabel4: UIButton!
    @IBAction func ChoiseBtn4(_ sender: Any) {
        validAnswer(button: ChoiseBtnLabel4)
        updateQuestion()
    }
    
    
}
