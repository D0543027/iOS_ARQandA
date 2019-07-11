//
//  UIAlertController+ValidName.swift
//  ARQandA
//
//  Created by 蔣聖訢 on 2019/7/10.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    func isValidName(_ name: String) -> Bool {
        // 名字最多 10 字，開頭不為空白，中間可以ㄈ
        return name.count > 0 && NSPredicate(format: "self matches %@","^[a-zA-Z0-9].{0,9}").evaluate(with: name)
    }
    
    
    @objc func textDidChangeInNameTextField() {
        if let name = textFields?[0].text,
            let action = actions.last {
            action.isEnabled = isValidName(name)
        }
    }
}
