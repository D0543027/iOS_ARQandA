//
//  TutorialViewController.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/7/5.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import UIKit
import AVFoundation

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var exitButton: UIButton!
    @IBAction func ExitButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "backToOption", sender: self)
    }
    @IBOutlet weak var pageControl: UIPageControl!
    
    var audioPlayerSP = AVAudioPlayer() //switch page
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exitButton.layer.cornerRadius = exitButton.frame.height / 2
        exitButton.isHidden = true
        exitButton.isEnabled = false
        // Do any additional setup after loading the view.
        do{
            let BS = URL(fileURLWithPath: Bundle.main.path(forResource:"switchPage", ofType:"mp3")!)
            try audioPlayerSP = AVAudioPlayer(contentsOf: BS)
        } catch let err as NSError {
            print(err.debugDescription)
        }
        audioPlayerSP.volume = 10
        audioPlayerSP.prepareToPlay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageViewController = segue.destination as? TutorialPageViewController {
            
            // 代理 pageViewController
            pageViewController.pageViewControllerDelegate = self
        }
    }
    
}

extension TutorialViewController: PageViewControllerDelegate {
    
    /// 設定總頁數
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - numberOfPage: _
    func pageViewController(_ pageViewController: TutorialPageViewController, didUpdateNumberOfPage numberOfPage: Int) {
        self.pageControl.numberOfPages = numberOfPage
    }
    
    /// 設定切換至第幾頁
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - pageIndex: _
    func pageViewController(_ pageViewController: TutorialPageViewController, didUpdatePageIndex pageIndex: Int) {
        audioPlayerSP.play()
        self.pageControl.currentPage = pageIndex

        if pageIndex == self.pageControl.numberOfPages - 1{
            exitButton.setTitle("End", for: .normal)
            exitButton.isHidden = false
            exitButton.isEnabled = true
        }
        else{
            exitButton.isHidden = true
            exitButton.isEnabled = false
        }
    
    }
}
