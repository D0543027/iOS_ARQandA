//
//  TutorialViewController.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/7/5.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
        self.pageControl.currentPage = pageIndex
    }
    
}
