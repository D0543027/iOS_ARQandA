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
    
    var label = ""              //object name
    var numberOfQuestion = ""   //numberOfQuestion
    
    var data: JSON?
    
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
        let parameters = ["label": self.label, "num": self.numberOfQuestion] //send parameters to server (query.php)
        
        Alamofire.request("https://8752d019.ngrok.io/query.php", method: .post, parameters: parameters).responseJSON(queue:queue, completionHandler:{ response in
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
        lb.text = self.data![index]["Question"].string
        
        RightAnswer = self.data![index]["Ans"].string
        
        // Default : Second button is the answer
        ChoiseBtnLabel1.setTitle(self.data![index]["choose1"].string, for: .normal)
        ChoiseBtnLabel2.setTitle(self.data![index]["Ans"].string, for: .normal)
        ChoiseBtnLabel3.setTitle(self.data![index]["choose3"].string, for: .normal)
        ChoiseBtnLabel4.setTitle(self.data![index]["choose4"].string, for: .normal)
        
        
        index = index + 1
        
        // End of QA
        if index == data!.count + 1{
            // TODO: add another action
            
            //
            
            dismiss(animated: true, completion: nil) // back to AR
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
