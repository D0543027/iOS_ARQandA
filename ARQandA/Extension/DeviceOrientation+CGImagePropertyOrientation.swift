//
//  DeviceOrientation+CGImagePropertyOrientation.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/7/10.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import Foundation
import ARKit

extension CGImagePropertyOrientation {
    init(_ deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portraitUpsideDown: self = .left
        case .landscapeLeft: self = .up
        case .landscapeRight: self = .down
        default: self = .right
        }
    }
}
