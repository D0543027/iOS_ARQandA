//
//  Audiomanager.swift
//  ARQandA
//
//  Created by 李其准 on 2019/7/10.
//  Copyright © 2019年 蔣聖訢. All rights reserved.
//

import AVFoundation

class AudioManager {
    static let sharedInstance = AudioManager()
    
    var musicPlayer: AVAudioPlayer?
    
    private init() {
    }
    
    func startMusic() {
        do {
            // Music BG
            let resourcePath = Bundle.main.path(forResource: "bgm", ofType: "mp3")
            let url = NSURL(fileURLWithPath: resourcePath!)
            try musicPlayer = AVAudioPlayer(contentsOf: url as URL)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.play()
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
    }
    
    func stopMusic(){
        musicPlayer?.stop()
    }
}
