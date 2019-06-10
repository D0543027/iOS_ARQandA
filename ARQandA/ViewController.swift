//
//  ViewController.swift
//  ARQ&A
//
//  Created by 蔣聖訢 on 2019/5/14.
//  Copyright © 2019 蔣聖訢. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import VideoToolbox

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    let yolo = YOLO()
    var request: VNCoreMLRequest!
    
    var colors: [UIColor] = []
    
    var boundingBoxes = [BoundingBox]()
    
    let visionQueue = DispatchQueue(label: "visionQueue")
    
    var new_MoveX: Float = 0.0
    var new_MoveY: Float = 0.0
    var new_MoveZ: Float = 0.0
    var new_RotateY: Float = 0.0
    
    var pre_MoveX: Float = 0.0
    var pre_MoveY: Float = 0.0
    var pre_MoveZ: Float = 0.0
    var pre_RotateY: Float = 0.0
    
    var currentBuffer: CVPixelBuffer?
    var button: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        setUpBoundingBoxes()
        setUpVision()
        
        for box in self.boundingBoxes {
            box.addToLayer(self.sceneView.layer)
        }
        
        print(UIScreen.main.bounds.size.width)
        print(UIScreen.main.bounds.size.height)
        
        //loopCoreMLUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    func session(_ session: ARSession, didUpdate frame: ARFrame){
        let currentTransform = frame.camera.transform
        new_MoveX = currentTransform.columns.3.x
        new_MoveY = currentTransform.columns.3.y
        new_MoveZ = currentTransform.columns.3.z
        
        
        //print("movement: \(new_MoveX),\(new_MoveY),\(new_MoveZ)")
        
        let rotation = frame.camera.eulerAngles
        new_RotateY = rotation.y
        //print("rotation: \(new_RotateY)")
        
        
        guard currentBuffer == nil else{ return }
        
        visionQueue.async {
            if self.DeviceMoving() == true {
                self.updatePosition()
                self.currentBuffer = frame.capturedImage
                self.predictUsingVision(pixelBuffer: self.currentBuffer!)
            }
        }
        
        //print("-----------------")
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     let DestViewController: ViewTwo = segue.destination as! ViewTwo
     //let rotateImage = (UIImage(pixelBuffer: myImage))?.image(withRotation: (.pi/2)*3)
     //let sendImage = rotateImage?.toCVPixelBuffer()
     DestViewController.image = sceneView.snapshot()
     
     }*/
    
    func setUpBoundingBoxes() {
        for _ in 0..<YOLO.maxBoundingBoxes {
            boundingBoxes.append(BoundingBox())
        }
        
        // Make colors for the bounding boxes. There is one color for each class,
        // 80 classes in total.
        for r: CGFloat in [0.2, 0.4, 0.6, 0.85, 1.0] {
            for g: CGFloat in [0.6, 0.7, 0.8, 0.9] {
                for b: CGFloat in [0.6, 0.7, 0.8, 1.0] {
                    let color = UIColor(red: r, green: g, blue: b, alpha: 1)
                    colors.append(color)
                }
            }
        }
    }
    
    func setUpVision() {
        guard let visionModel = try? VNCoreMLModel(for: yolo.model.model) else {
            print("Error: could not create Vision model")
            return
        }
        
        request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
        
        // NOTE: If you choose another crop/scale option, then you must also
        // change how the BoundingBox objects get scaled when they are drawn.
        // Currently they assume the full input image is used.
        request.imageCropAndScaleOption = .scaleFill
    }
    /*
    func loopCoreMLUpdate() {
        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
        
        visionQueue.async {
            // 1. Run Update.
            //self.semaphore.wait()
            
            
            self.updateCoreML()
            
            // 2. Loop this function.
            //self.semaphore.signal()
            
            self.loopCoreMLUpdate()
        }
        
    }
    
    func updateCoreML() {
        
        if DeviceMoving() {
            updatePosition()
            
            //print("predicting...")
            
            let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
            if pixbuff == nil { return }
            
            //myImage = pixbuff
            //let rotateImage = (UIImage(pixelBuffer: pixbuff!))!.image(withRotation: (.pi/2)*3)
            predictUsingVision(pixelBuffer: pixbuff!)
        }
    }
    */
    
    func DeviceMoving() -> Bool{
        if abs(self.pre_MoveX - self.new_MoveX) > 0.03{
            return true;
        }
        if abs(self.pre_MoveY - self.new_MoveY) > 0.03{
            return true;
        }
        if abs(self.pre_MoveZ - self.new_MoveZ) > 0.05{
            return true;
        }
        if abs(self.pre_RotateY - self.new_RotateY) > 0.2{
            return true;
        }
        return false;
    }
    
    func updatePosition(){
        self.pre_MoveX = self.new_MoveX
        self.pre_MoveY = self.new_MoveY
        self.pre_MoveZ = self.new_MoveZ
        self.pre_RotateY = self.new_RotateY
    }
    
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        /*
         let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)
         
         let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,orientation: orientation)
         
         try? handler.perform([request])
         */
        
        let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation)
        visionQueue.async {
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentBuffer = nil }
                try requestHandler.perform([self.request])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let features = observations.first?.featureValue.multiArrayValue {
            
            let boundingBoxes = yolo.computeBoundingBoxes(features: features)
            showOnMainThread(boundingBoxes)
        }
    }
    
    func showOnMainThread(_ boundingBoxes: [YOLO.Prediction]) {
        DispatchQueue.main.async {
            self.clear()
            self.show(predictions: boundingBoxes)
            
        }
    }
    
    func clear(){
        for view in self.sceneView.subviews{
            view.removeFromSuperview()
        }
        
        for i in 0..<boundingBoxes.count{
            boundingBoxes[i].hide()
        }
    }
    
    func show(predictions: [YOLO.Prediction]) {
        for i in 0..<boundingBoxes.count {
            //boundingBoxes[i].hide()
            if i < predictions.count {
                let prediction = predictions[i]
                
                let rect = scaledRect(rect: prediction.rect)
                
                // Show the bounding box.
                let label = labels[prediction.classIndex]
                let confidence = prediction.score * 100
                let color = colors[prediction.classIndex]

                if(rect.size.width > 100 && rect.size.width > 100){
                    addButton(frame: CGRect(x:rect.origin.x + rect.size.width - 55, y: rect.origin.y + rect.size.height - 55, width: 50, height: 50))
                    boundingBoxes[i].show(frame: rect, label: label, confidence: confidence, color: color)
                }
            }
        }
    }
    
    func scaledRect(rect: CGRect) -> CGRect{
        
        // The predicted bounding box is in the coordinate space of the input
        // image, which is a square image of 416x416 pixels. We want to show it
        // on the video preview, which is as wide as the screen and has a 4:3
        // aspect ratio. The video preview also may be letterboxed at the top
        // and bottom.
        let width = view.bounds.width
        let height = width * 4 / 3
        let scaleX = width / CGFloat(YOLO.inputWidth)
        let scaleY = height / CGFloat(YOLO.inputHeight)
        let top = (view.bounds.height - height) / 2
        
        // Translate and scale the rectangle to our own coordinate system.
        var newRect = rect
        newRect.origin.x *= scaleX
        newRect.origin.y *= scaleY
        newRect.origin.y += top
        newRect.size.width *= scaleX
        newRect.size.height *= scaleY
        
        if newRect.origin.x < 0.0 {
            newRect.origin.x = 0.0
        }
        if newRect.origin.y < 0.0{
            newRect.origin.y = 0.0
        }
        if newRect.origin.x + newRect.size.width > UIScreen.main.bounds.width{
            newRect.size.width = UIScreen.main.bounds.width - newRect.origin.x
        }
        if newRect.origin.y + newRect.size.height > UIScreen.main.bounds.height{
            newRect.size.height = UIScreen.main.bounds.height - newRect.origin.y
        }
        
        return newRect
    }
    
    func addButton(frame:CGRect){
        
        button = UIButton(frame:frame )
        button.backgroundColor = .green
        button.setTitle("Go", for: .normal)
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0.0
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 4.0
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.sceneView.addSubview(button)
    }
    
    @objc func buttonAction(sender: UIButton!){
        print("Button tapped")
        
    }
    
}


/*
 extension UIImage {
 public convenience init?(pixelBuffer: CVPixelBuffer) {
 var cgImage: CGImage?
 VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
 
 if let cgImage = cgImage {
 self.init(cgImage: cgImage)
 } else {
 return nil
 }
 }
 
 func image(withRotation radians: CGFloat) -> UIImage {
 let cgImage = self.cgImage!
 let LARGEST_SIZE = CGFloat(max(self.size.width, self.size.height))
 let context = CGContext.init(data: nil, width:Int(LARGEST_SIZE), height:Int(LARGEST_SIZE), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!
 
 var drawRect = CGRect.zero
 drawRect.size = self.size
 let drawOrigin = CGPoint(x: (LARGEST_SIZE - self.size.width) * 0.5,y: (LARGEST_SIZE - self.size.height) * 0.5)
 drawRect.origin = drawOrigin
 var tf = CGAffineTransform.identity
 tf = tf.translatedBy(x: LARGEST_SIZE * 0.5, y: LARGEST_SIZE * 0.5)
 tf = tf.rotated(by: CGFloat(radians))
 tf = tf.translatedBy(x: LARGEST_SIZE * -0.5, y: LARGEST_SIZE * -0.5)
 context.concatenate(tf)
 context.draw(cgImage, in: drawRect)
 var rotatedImage = context.makeImage()!
 
 drawRect = drawRect.applying(tf)
 
 rotatedImage = rotatedImage.cropping(to: drawRect)!
 let resultImage = UIImage(cgImage: rotatedImage)
 return resultImage
 }
 
 func toCVPixelBuffer() -> CVPixelBuffer? {
 let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
 var pixelBuffer : CVPixelBuffer?
 let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
 guard status == kCVReturnSuccess else {
 return nil
 }
 
 if let pixelBuffer = pixelBuffer {
 CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
 let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
 
 let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
 let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
 
 context?.translateBy(x: 0, y: self.size.height)
 context?.scaleBy(x: 1.0, y: -1.0)
 
 UIGraphicsPushContext(context!)
 self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
 UIGraphicsPopContext()
 CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
 
 return pixelBuffer
 }
 
 return nil
 }
 }
 */
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
