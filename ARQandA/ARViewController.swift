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
import AVFoundation

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBAction func toQAButtonTapped(_ sender: Any) {
        print(tappedPredictionLabel)
        guard let difficulty = difficultyOfLabels[tappedPredictionLabel] else{
            return
        }
        numberOfQuestion = Difficult_Number_Dict[difficulty]
        self.performSegue(withIdentifier: "switchToQA", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? QAViewController{
            dest.label = self.tappedPredictionLabel
            dest.numberOfQuestion = self.numberOfQuestion
        }
    }
    @IBOutlet weak var toQAButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    let yolo = YOLO()
    var request: VNCoreMLRequest!
    
    var boundingBoxes = [BoundingBox]()
    var colors: [UIColor] = []
    var shapeLayerArray: [CAShapeLayer] = []
    var isTapped: [Bool] = []
    var predictLabel: [String] = []
    var tappedPredictionLabel: String = "..."
    private var Difficult_Number_Dict  = ["Easy": "3", "Normal": "5", "Hard": "7"]
    private var numberOfQuestion: String! = ""
    
    let visionQueue = DispatchQueue(label: "visionQueue")
    
    
    var currentBuffer: CVPixelBuffer?

    
    let backButton = UIButton()
    var backButtonWidth = 70
    var backButtonHeight = 70
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        setUpBackBtn()
        setUpBoundingBoxes()
        setUpVision()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)

        toQAButton.layer.masksToBounds = false
        toQAButton.layer.cornerRadius = 4.0
        toQAButton.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        toQAButton.titleLabel?.font = UIFont(name: "AthensClassic", size: 25.0)
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
    
    
    fileprivate func setUpBackBtn() {
        backButton.frame = CGRect(x: 15, y: 50, width: backButtonWidth, height: backButtonHeight)
        backButton.layer.cornerRadius = backButton.bounds.width / 2
        backButton.setTitle("<", for: .normal)
        backButton.setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)
        backButton.titleLabel?.font = UIFont(name: "AthensClassic", size: CGFloat(backButtonWidth / 2 + 10))
        backButton.contentHorizontalAlignment = .center
        backButton.contentVerticalAlignment = .center
        backButton.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        
        backButton.addTarget(self, action: #selector(backToMenu), for: .touchUpInside)
        view.addSubview(backButton)
    }
    
    @objc func backToMenu(sender: UIButton){
        dismiss(animated: true, completion: nil);
    }
    
    
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
    
    var new_MoveX: Float = 0.0
    var new_MoveY: Float = 0.0
    var new_MoveZ: Float = 0.0
    var new_RotateY: Float = 0.0
    
    var pre_MoveX: Float = 0.0
    var pre_MoveY: Float = 0.0
    var pre_MoveZ: Float = 0.0
    var pre_RotateY: Float = 0.0
    
    func session(_ session: ARSession, didUpdate frame: ARFrame){
        let currentTransform = frame.camera.transform
        new_MoveX = currentTransform.columns.3.x
        new_MoveY = currentTransform.columns.3.y
        new_MoveZ = currentTransform.columns.3.z
        
        
        //print("movement: \(new_MoveX),\(new_MoveY),\(new_MoveZ)")
        
        let rotation = frame.camera.eulerAngles
        new_RotateY = rotation.y
        
        
        guard currentBuffer == nil else{ return }
        
        visionQueue.async {
            if self.DeviceMoving() == true && rotation.z >= -2.2 && rotation.z <= -0.8 {
                self.shapeLayerArray.removeAll()
                self.predictLabel.removeAll()
                self.isTapped.removeAll()
                self.sceneView.scene.rootNode.enumerateChildNodes{
                    (node,stop) in
                    node.removeFromParentNode()
                }
                self.updatePosition()
                self.currentBuffer = frame.capturedImage
                self.predictUsingVision(pixelBuffer: self.currentBuffer!)
            }
            
        }
    }
    
    func DeviceMoving() -> Bool{
        if abs(self.pre_MoveX - self.new_MoveX) > 0.015{
            return true;
        }
        if abs(self.pre_MoveY - self.new_MoveY) > 0.015{
            return true;
        }
        if abs(self.pre_MoveZ - self.new_MoveZ) > 0.015{
            return true;
        }
        if abs(self.pre_RotateY - self.new_RotateY) > 0.1{
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
            
            for box in self.boundingBoxes {
                box.addToLayer(self.view.layer)
            }
            self.clear()
            self.show(predictions: boundingBoxes)
            
        }
    }
    
    // clear all items before showing the new result
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
            if i < predictions.count {
                let prediction = predictions[i]
                
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
                var rect = prediction.rect
                rect.origin.x *= scaleX
                rect.origin.y *= scaleY
                rect.origin.y += top
                rect.size.width *= scaleX
                rect.size.height *= scaleY
                
                // Show the bounding box.
                let label = String(format: "%@ %.1f", labels[prediction.classIndex], prediction.score * 100)
                let color = colors[prediction.classIndex]
                boundingBoxes[i].show(frame: rect, label: label, color: color)
                shapeLayerArray.append(boundingBoxes[i].shapeLayer)
                predictLabel.append(labels[prediction.classIndex])
                isTapped.append(false)
            } else {
                boundingBoxes[i].hide()
            }
        }
    }
    
    var touchPosition: CGPoint!
    
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        
        touchPosition = gestureRecognize.location(in: self.view)
        
        for i in 0..<shapeLayerArray.count{
            if shapeLayerArray[i].path!.contains(touchPosition){
                tappedPredictionLabel = predictLabel[i]
                print(tappedPredictionLabel)
                if isTapped[i] == false{
                    isTapped[i] = true
                    let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(touchPosition, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
                    
                    if let closestResult = arHitTestResults.first {
                        // Get Coordinates of HitTest
                        let transform : matrix_float4x4 = closestResult.worldTransform
                        let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                        
                        
                        // Create 3D Text
                        let node : SCNNode = createNewBubbleParentNode(tappedPredictionLabel)
                        sceneView.scene.rootNode.addChildNode(node)
                        node.position = worldCoord
                        
                        let starNode: SCNNode = createStar(x0:0 , y: 0)
                        sceneView.scene.rootNode.addChildNode(starNode)
                        starNode.position = SCNVector3Make(transform.columns.3.x + 0.01, transform.columns.3.y - 0.03, transform.columns.3.z)
                    }
                }
                break
            }
        }
        // HIT TEST : REAL WORLD
        // Get Screen Centre
        //let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
    }
    
    func createNewBubbleParentNode(_ text : String) -> SCNNode {
        // Warning: Creating 3D Text is susceptible to crashing. To reduce chances of crashing; reduce number of polygons, letters, smoothness, etc.
        
        // TEXT BILLBOARD CONSTRAINT
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // BUBBLE-TEXT
        let bubbleDepth : Float = 0.01 // the 'depth' of 3D text
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        var font = UIFont(name: "Futura", size: 0.15)
        font = font?.withTraits(traits: .traitBold)
        bubble.font = font
        bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        bubble.firstMaterial?.diffuse.contents = UIColor.orange
        bubble.firstMaterial?.specular.contents = UIColor.white
        bubble.firstMaterial?.isDoubleSided = true
        // bubble.flatness // setting this too low can cause crashes.
        bubble.chamferRadius = CGFloat(bubbleDepth)
        
        // BUBBLE NODE
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        // Centre Node - to Centre-Bottom point
        bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2)
        // Reduce default text size
        bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        
        // BUBBLE PARENT NODE
        let bubbleNodeParent = SCNNode()
        bubbleNodeParent.addChildNode(bubbleNode)
        bubbleNodeParent.constraints = [billboardConstraint]
        
        return bubbleNodeParent
    }
    
    func createStar(x0: CGFloat, y: CGFloat) -> SCNNode{
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        var x: CGFloat = x0
        let path = UIBezierPath()
        for _ in 1...5{
            path.move(to: CGPoint(x: x, y: 0.02))  //A
            path.addLine(to: CGPoint(x: x + 0.01, y: 0)) //B
            path.addLine(to: CGPoint(x: x + 0.03, y: 0)) //C
            path.addLine(to: CGPoint(x: x + 0.01, y: -0.01)) //D
            path.addLine(to: CGPoint(x: x + 0.02, y: -0.03)) //E
            path.addLine(to: CGPoint(x: x + 0, y: -0.02))   //F
            path.addLine(to: CGPoint(x: x + -0.02, y: -0.03))//G
            path.addLine(to: CGPoint(x: x + -0.01, y: -0.01))   //H
            path.addLine(to: CGPoint(x: x + -0.03, y: 0))//I
            path.addLine(to: CGPoint(x: x + -0.01, y: 0))//J
            path.addLine(to: CGPoint(x: x, y: 0.02))
            x = x + 0.08
        }
        let shape = SCNShape(path: path, extrusionDepth: 0.0)
        let color = #colorLiteral(red: 0.9915831685, green: 1, blue: 0, alpha: 1)
        shape.firstMaterial?.diffuse.contents = color
        
        
        let (minBound, maxBound) = shape.boundingBox
        let starNode = SCNNode(geometry: shape)
        starNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, 0)
        starNode.scale = SCNVector3Make(0.35, 0.35, 0.35)
        
        
        // BUBBLE PARENT NODE
        let starNodeParent = SCNNode()
        starNodeParent.addChildNode(starNode)
        starNodeParent.constraints = [billboardConstraint]
        
        return starNodeParent
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
    
}


extension UIFont {
    // Based on: https://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
