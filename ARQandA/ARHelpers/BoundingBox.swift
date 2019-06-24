import Foundation
import UIKit

class BoundingBox{
    let shapeLayer: CAShapeLayer
    //let textLayer: CATextLayer
    //let infoLayer: CAShapeLayer
    let infoTextLayer: CATextLayer
    let starLayer: CAShapeLayer
    
    init() {
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor =  UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8).cgColor
        shapeLayer.isHidden = true
        
        /*
         textLayer = CATextLayer()
         textLayer.foregroundColor = UIColor.black.cgColor
         textLayer.isHidden = true
         textLayer.contentsScale = UIScreen.main.scale
         textLayer.fontSize = 14
         textLayer.font = UIFont(name: "Avenir", size: textLayer.fontSize)
         textLayer.alignmentMode = CATextLayerAlignmentMode.center
         */
        /*
         infoLayer = CAShapeLayer()
         infoLayer.lineWidth = 4
         infoLayer.isHidden = true
         
         */
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
    }
    
    
    func addToLayer(_ parent: CALayer) {
        parent.addSublayer(shapeLayer)
        //parent.addSublayer(textLayer)
        //parent.addSublayer(infoLayer)
        parent.addSublayer(infoTextLayer)
        parent.addSublayer(starLayer)
        
    }
    
    func show(frame: CGRect, label: String, confidence: Float, color: UIColor,difficulty: String, number: String) {
        CATransaction.setDisableActions(true)
        
        let infoRect = CGRect(x: frame.origin.x + 50 + 10, y: frame.origin.y + 5, width: 150, height: 100)
        let rect = CGRect(x:frame.origin.x, y:frame.origin.y, width: 220, height: 70)
        let path = UIBezierPath(rect: rect)
        //let infoPath = UIBezierPath(rect: infoRect)
        
        
        shapeLayer.path = path.cgPath
        //shapeLayer.strokeColor = color.cgColor
        shapeLayer.isHidden = false
        
        /*
         textLayer.string = label
         textLayer.backgroundColor = color.cgColor
         textLayer.isHidden = false
         */
        
        /*
         infoLayer.path = infoPath.cgPath
         infoLayer.isHidden = false
         infoLayer.fillColor = UIColor.yellow.cgColor
         */
        
        let infoText = "Name: " + label
        
        infoTextLayer.string = infoText
        infoTextLayer.isWrapped = false
        infoTextLayer.alignmentMode = .left
        
        infoTextLayer.backgroundColor = UIColor.clear.cgColor
        
        var starCount = 0
        switch difficulty {
        case "Easy":
            starCount = 1
        case "Normal":
            starCount = 3
        case "Hard":
            starCount = 5
        default:
            starCount = 0
        }
        
        infoTextLayer.isHidden = false
        
        let infoTextSize = CGSize(width: infoRect.width, height: infoRect.height)
        
        let infoTextOrigin = CGPoint(x: infoRect.origin.x , y: infoRect.origin.y)
        infoTextLayer.frame = CGRect(origin: infoTextOrigin, size: infoTextSize)
        
        /*
         let attributes = [
         NSAttributedString.Key.font: textLayer.font as Any
         ]
         
         let textRect = label.boundingRect(with: CGSize(width: 400, height: 100),
         options: .truncatesLastVisibleLine,
         attributes: attributes, context: nil)
         let textSize = CGSize(width: textRect.width + 12, height: textRect.height)
         let textOrigin = CGPoint(x: frame.origin.x - 2, y: frame.origin.y - textSize.height)
         textLayer.frame = CGRect(origin: textOrigin, size: textSize)
         */
        
        
        starLayer.path = drawStar(x: frame.origin.x + 75, y: frame.origin.y + 45, starCount: starCount).cgPath
        
        starLayer.isHidden = false
    }
    
    func hide() {
        shapeLayer.isHidden = true
        // textLayer.isHidden = true
        //infoLayer.isHidden = true
        infoTextLayer.isHidden = true
        starLayer.isHidden = true
    }
    
    func drawStar(x: CGFloat,y: CGFloat,starCount: Int) -> UIBezierPath{
        let starPath = UIBezierPath()
        
        var xCenter: CGFloat = x
        var yCenter: CGFloat = y
        
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
        starPath.close()
        return starPath
    }
}
