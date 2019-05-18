import Foundation
import UIKit

class BoundingBox {
    let shapeLayer: CAShapeLayer
    let textLayer: CATextLayer
    let infoLayer: CAShapeLayer
    let infoTextLayer: CATextLayer
    
    init() {
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.isHidden = true
        
        textLayer = CATextLayer()
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.isHidden = true
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = 14
        textLayer.font = UIFont(name: "Avenir", size: textLayer.fontSize)
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        
        infoLayer = CAShapeLayer()
        infoLayer.fillColor = UIColor.white.cgColor
        infoLayer.lineWidth = 4
        infoLayer.isHidden = true
        
        infoTextLayer = CATextLayer()
        infoTextLayer.foregroundColor = UIColor.black.cgColor
        infoTextLayer.isHidden = true
        infoTextLayer.contentsScale = UIScreen.main.scale
        infoTextLayer.fontSize = 14
        infoTextLayer.font = UIFont(name: "Avenir", size: infoTextLayer.fontSize)
        infoTextLayer.alignmentMode = CATextLayerAlignmentMode.center
    }
    
    func addToLayer(_ parent: CALayer) {
        parent.addSublayer(shapeLayer)
        parent.addSublayer(textLayer)
        parent.addSublayer(infoLayer)
        parent.addSublayer(infoTextLayer)
    }
    
    func show(frame: CGRect, label: String, color: UIColor) {
        CATransaction.setDisableActions(true)
        
        let infoRect = CGRect(x: frame.origin.x - frame.size.width, y: frame.origin.y, width: frame.size.width, height: 150)
        
        let path = UIBezierPath(rect: frame)
        let infoPath = UIBezierPath(rect: infoRect)
        
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.isHidden = false
        
        textLayer.string = label
        textLayer.backgroundColor = color.cgColor
        textLayer.isHidden = false
        
        infoLayer.path = infoPath.cgPath
        infoLayer.isHidden = false
        
        let infoText = "Name: 123456\nDifficulty: Easy\nNumber: 5 "
        infoTextLayer.string = infoText
        infoTextLayer.isWrapped = false
        infoTextLayer.alignmentMode = .left
        infoTextLayer.backgroundColor = UIColor.white.cgColor
        infoTextLayer.isHidden = false
        
        
        
        let attributes = [
            NSAttributedString.Key.font: textLayer.font as Any
        ]
        
        let textRect = label.boundingRect(with: CGSize(width: 400, height: 100),
                                          options: .truncatesLastVisibleLine,
                                          attributes: attributes, context: nil)
        let textSize = CGSize(width: textRect.width + 12, height: textRect.height)
        let textOrigin = CGPoint(x: frame.origin.x - 2, y: frame.origin.y - textSize.height)
        textLayer.frame = CGRect(origin: textOrigin, size: textSize)
        

        let infoTextSize = CGSize(width: infoRect.width, height: infoRect.height)
        
        let infoTextOrigin = CGPoint(x: infoRect.origin.x , y: infoRect.origin.y)
        infoTextLayer.frame = CGRect(origin: infoTextOrigin, size: infoTextSize)
        
    }
    
    func hide() {
        shapeLayer.isHidden = true
        textLayer.isHidden = true
        infoLayer.isHidden = true
        infoTextLayer.isHidden = true
    }
    
    
}
