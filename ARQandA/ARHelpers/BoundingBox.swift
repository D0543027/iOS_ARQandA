import Foundation
import UIKit

class BoundingBox{
    let shapeLayer: CAShapeLayer

    let infoTextLayer: CATextLayer
    let starLayer: CAShapeLayer
    var starWidth: CGFloat
    init() {
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor =  UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8).cgColor
        shapeLayer.isHidden = true
        
        infoTextLayer = CATextLayer()
        infoTextLayer.foregroundColor = UIColor.black.cgColor
        infoTextLayer.isHidden = true
        infoTextLayer.contentsScale = UIScreen.main.scale
        infoTextLayer.fontSize = 20
        infoTextLayer.font = UIFont(name: "Avenir", size: infoTextLayer.fontSize)
        infoTextLayer.alignmentMode = CATextLayerAlignmentMode.center
        
        starLayer = CAShapeLayer()
        starLayer.fillColor = UIColor.black.cgColor
        starLayer.isHidden = true
        
        starWidth = 0.0
    }
    
    
    func addToLayer(_ parent: CALayer) {
        parent.addSublayer(shapeLayer)
        parent.addSublayer(infoTextLayer)
        parent.addSublayer(starLayer)
        
    }
    
    func show(frame: CGRect, label: String,difficulty: String) {
        CATransaction.setDisableActions(true)
        
        // 顯示出 Name: Label
        let infoText = "Name: " + label
        infoTextLayer.string = infoText
        infoTextLayer.isWrapped = false
        infoTextLayer.alignmentMode = .left
        infoTextLayer.backgroundColor = UIColor.clear.cgColor
        infoTextLayer.isHidden = false
        let infoTextSize = getSizeFromString(string: infoText, withFont: UIFont(name: "Avenir", size: infoTextLayer.fontSize)!)
        let infoTextOrigin = CGPoint(x: frame.origin.x + 50 + 10 , y: frame.origin.y + 5)
        infoTextLayer.frame = CGRect(origin: infoTextOrigin, size: infoTextSize)
        
        // 畫星星
        let starCount = getStarCountByDifficulty(difficulty: difficulty)
        starLayer.path = drawStar(x: frame.origin.x + 75, y: frame.origin.y + 45, starCount: starCount).cgPath
        starLayer.isHidden = false
        
        // 整個包起來
        var newFrame = frame
        newFrame.size.width = computeWidthForShapeLayer(textWidth: infoTextOrigin.x + infoTextSize.width, starWidth: starWidth) - newFrame.origin.x
        let path = UIBezierPath(rect: newFrame)
        shapeLayer.path = path.cgPath
        shapeLayer.isHidden = false
    }
    
    func hide() {
        shapeLayer.isHidden = true
        infoTextLayer.isHidden = true
        starLayer.isHidden = true
    }
    
    private func getStarCountByDifficulty(difficulty: String) -> Int{
        switch difficulty {
        case "Easy":
            return 1
        case "Normal":
            return 3
        case "Hard":
            return 5
        default:
            return 0
        }
    }
    private func drawStar(x: CGFloat,y: CGFloat,starCount: Int) -> UIBezierPath{
        let starPath = UIBezierPath()
        
        var xCenter: CGFloat = x
        let yCenter: CGFloat = y
        
        let w = CGFloat(20)
        let r = w / 2.0
        let flip: CGFloat = -1.0 // use this to flip the figure 1.0 or -1.0
        
        let starSide = CGFloat(5)
        
        let theta = 2.0 * Double.pi * Double(2.0 / starSide)
        
        for _ in 1...starCount{
            starPath.move(to: CGPoint(x: xCenter, y: r * flip + yCenter))
            
            for i in 1..<Int(starSide) {
                let x: CGFloat = r * CGFloat( sin(Double(i) * theta) )
                let y: CGFloat = r * CGFloat( cos(Double(i) * theta) )
                starPath.addLine(to: CGPoint(x: x + xCenter, y: y * flip + yCenter))
            }
            
            xCenter = xCenter + 25
        }
        starWidth = xCenter
        starPath.close()
        return starPath
    }
    
    private func getSizeFromString(string:String, withFont font:UIFont)->CGSize{
        
        let textSize = NSString(string: string ).size(
            withAttributes: [ NSAttributedString.Key.font:font ])
        
        return textSize
    }
    
    private func computeWidthForShapeLayer(textWidth: CGFloat, starWidth: CGFloat) -> CGFloat{
        if textWidth >= starWidth{
            return textWidth + 15
        }
        else{
            return starWidth
        }
        
    }
}
