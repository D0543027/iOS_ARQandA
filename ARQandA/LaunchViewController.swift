//
//  LaunchView.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/6/19.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        FirstLaunch()
    }
    
    // 第一次開啟APP，創建一個儲存空間用來儲存分數，Key為score，值為0
    func FirstLaunch(){
        if UserDefaults.standard.object(forKey: "score") == nil{
            UserDefaults.standard.set(0, forKey: "score")
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
        performSegue(withIdentifier: "ToMenu", sender: sender)
    }
}
