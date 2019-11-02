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
    
    @IBOutlet var sceneView: ARSCNView!
    let yolo = YOLO()
    var request: VNCoreMLRequest!
    
    var colors: [UIColor] = []
    var boundingBoxArray: [CAShapeLayer] = []
    var predictLabelArray: [String] = []
    var tappedPredictionLabel: String = "..."
    var labelNodeOnScreen = SCNNode()
    var starNodeOnScreen = SCNNode()
    var Diffucult_StarCount_Dict = ["Easy": 1, "Normal": 3, "Hard": 5]
    
    var difficulty: String! = ""
    
    let visionQueue = DispatchQueue(label: "visionQueue")
    
    let ciContext = CIContext()
    var resizedPixelBuffer: CVPixelBuffer?
    var currentbuffer: CVPixelBuffer?
    
    let toQAButton = UIButton()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        // 三個按鈕function，看哪個按鈕要加音效，直接打code在function裡
        setUpQAButton()
        setUpBackBtn()
        setUpPredictButton()
        
        setUpBoundingBoxesColor()
        setUpVision()
        setUpCoreImage()
        addTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.debugOptions.insert(SCNDebugOptions.showFeaturePoints)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.debugOptions = []
        sceneView.session.pause()
        request = nil
        
    }
    
    fileprivate func setUpBackBtn() {
        let backButton = UIButton()
        let backButtonWidth = 70
        let backButtonHeight = 70
        
        backButton.frame = CGRect(x: 15, y: 50, width: backButtonWidth, height: backButtonHeight)
        backButton.layer.cornerRadius = backButton.bounds.width / 2
        backButton.setTitle("<", for: .normal)
        backButton.setTitleColor(UIColor(white: 0, alpha: 1), for: .normal)
        backButton.titleLabel?.font = UIFont(name: "AthensClassic", size: CGFloat(backButtonWidth / 2 + 10))
        backButton.contentHorizontalAlignment = .center
        backButton.contentVerticalAlignment = .center
        backButton.backgroundColor = UIColor(white: 1, alpha: 1)
        backButton.layer.borderColor = UIColor.blue.cgColor
        backButton.layer.borderWidth = 2
        
        
        backButton.addTarget(self, action: #selector(backToMenu), for: .touchUpInside) //觸發動作
        view.addSubview(backButton)
    }
    
    @objc func backToMenu(sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setUpQAButton(){
        let deviceWidth = UIScreen.main.bounds.width
        let deviceHeight = UIScreen.main.bounds.height
        
        let buttonWidth:CGFloat = 70
        let buttonHeight:CGFloat = 70
        toQAButton.frame = CGRect(x: deviceWidth - buttonWidth - 10, y: deviceHeight - buttonHeight - 20, width: buttonWidth, height: buttonHeight)
        toQAButton.layer.masksToBounds = false
        toQAButton.layer.cornerRadius = buttonWidth / 2
        toQAButton.layer.borderColor = UIColor.blue.cgColor
        toQAButton.layer.borderWidth = 2
        toQAButton.backgroundColor = UIColor(white: 1, alpha: 1)
        toQAButton.setTitle("QA", for: .normal)
        toQAButton.setTitleColor(UIColor(white: 0, alpha: 1), for: .normal)
        toQAButton.titleLabel?.font = UIFont(name: "AthensClassic", size: CGFloat(buttonWidth / 2 + 10))
        toQAButton.contentHorizontalAlignment = .center
        toQAButton.contentVerticalAlignment = .center
        toQAButton.addTarget(self, action: #selector(toQAButtonTapped), for: .touchUpInside) //觸發動作
        toQAButton.isEnabled = false
        view.addSubview(toQAButton)
        toQAButton.isHidden = true
    }
    
    @objc func toQAButtonTapped(_ sender: UIButton) {
        for shape in boundingBoxArray{
            shape.isHidden = true
        }
        predictLabelArray.removeAll()
        sceneView.scene.rootNode.enumerateChildNodes{
            (node,stop) in
            node.removeFromParentNode()
        }
        sceneView.debugOptions = []
        sceneView.session.pause()
        toQAButton.isEnabled = false
        toQAButton.isHidden = true
        self.performSegue(withIdentifier: "switchToQA", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? QAViewController{
            dest.label = self.tappedPredictionLabel
            dest.difficulty = self.difficulty
        }
    }
    
    func setUpCoreImage() {
        let status = CVPixelBufferCreate(nil, YOLO.inputWidth, YOLO.inputHeight,
                                         kCVPixelFormatType_32BGRA, nil,
                                         &resizedPixelBuffer)
        if status != kCVReturnSuccess {
            print("Error: could not create resized pixel buffer", status)
        }
    }
    
    func setUpPredictButton(){
        let predictButton = UIButton()
        let buttonWidth:CGFloat = 70
        let buttonHeight:CGFloat = 70
        let deviceHeight = UIScreen.main.bounds.height
        
        predictButton.frame = CGRect(x: 15, y: deviceHeight - buttonHeight - 20, width: buttonWidth, height: buttonHeight)
        predictButton.layer.cornerRadius = predictButton.bounds.width / 2
        predictButton.setImage(UIImage(named: "eyes.png"), for: .normal)
        predictButton.layer.borderColor = UIColor.blue.cgColor
        predictButton.layer.borderWidth = 2
        predictButton.backgroundColor = UIColor(white: 1, alpha: 1)
        predictButton.addTarget(self, action: #selector(predictButtonTapped), for: .touchUpInside) //觸發動作
        predictButton.isEnabled = true
        view.addSubview(predictButton)
    }
    
    @objc func predictButtonTapped(_ sender: UIButton){
        print("Button Tapped...")
        let rotation = sceneView.session.currentFrame!.camera.eulerAngles
        if rotation.z <= -0.8 && rotation.z >= -2.5{
            //點擊預測按鈕後，先清除原本在螢幕中的物件
            clearShapeArray()
            toQAButton.isHidden = true
            toQAButton.isEnabled = false
            self.predictLabelArray.removeAll()
            labelNodeOnScreen.removeFromParentNode()
            starNodeOnScreen.removeFromParentNode()
            
            if currentbuffer == nil{
                //擷取當下畫面
                currentbuffer = sceneView.session.currentFrame?.capturedImage
                //預測
                visionQueue.async {
                    self.predict(pixelBuffer: self.currentbuffer!)
                }
            }
        }
        else{
            let alertController = UIAlertController(title: "手機請拿直的", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "知道了", style: .cancel))
            present(alertController, animated: true)
        }
    }
    
    func setUpBoundingBoxesColor() {
        for r: CGFloat in [0.2, 0.4, 0.6, 0.8, 1.0] {
            for g: CGFloat in [0.3, 0.7, 0.6, 0.8] {
                for b: CGFloat in [0.4, 0.8, 0.6, 1.0] {
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
    
    
    fileprivate func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
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
        
        
        // print("movement: \(new_MoveX),\(new_MoveY),\(new_MoveZ)")
        
        let rotation = frame.camera.eulerAngles
        new_RotateY = rotation.y
        
        if self.DeviceMoving() == true{
            print("Moving...")
            clearShapeArray()
            self.updatePosition()
        }
    }
    
    func DeviceMoving() -> Bool{
        if abs(self.pre_MoveX - self.new_MoveX) > 0.25{
            return true;
        }
        if abs(self.pre_MoveY - self.new_MoveY) > 0.25{
            return true;
        }
        if abs(self.pre_MoveZ - self.new_MoveZ) > 0.25{
            return true;
        }
        if abs(self.pre_RotateY - self.new_RotateY) > 0.25{
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
    
    func clearShapeArray(){
        for shape in self.boundingBoxArray{
            shape.removeFromSuperlayer()
        }
        self.boundingBoxArray.removeAll()
    }
    
    func predict(image: UIImage) {
        if let pixelBuffer = image.pixelBuffer(width: YOLO.inputWidth, height: YOLO.inputHeight) {
            predict(pixelBuffer: pixelBuffer)
        }
    }
    
    func predict(pixelBuffer: CVPixelBuffer) {
        // Measure how long it takes to predict a single video frame.
        
        // Resize the input with Core Image to 416x416.
        guard let resizedPixelBuffer = resizedPixelBuffer else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let sx = CGFloat(YOLO.inputWidth) / CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let sy = CGFloat(YOLO.inputHeight) / CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
        let scaledImage = ciImage.transformed(by: scaleTransform)
        let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)
        let rotateImage = scaledImage.oriented(orientation)
        /*
         DispatchQueue.main.async {
         self.debugView.image = UIImage(ciImage: rotateImage)
         }
         */
        ciContext.render(rotateImage, to: resizedPixelBuffer)
        
        // This is an alternative way to resize the image (using vImage):
        //if let resizedPixelBuffer = resizePixelBuffer(pixelBuffer,
        //                                              width: YOLO.inputWidth,
        //                                              height: YOLO.inputHeight)
        
        // Resize the input to 416x416 and give it to our model.
        if let boundingBoxes = try? yolo.predict(image: resizedPixelBuffer) {
            // let elapsed = CACurrentMediaTime() - startTime
            showOnMainThread(boundingBoxes)
        }
    }
    /*
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
     */
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let features = observations.first?.featureValue.multiArrayValue {
            
            let boundingBoxes = yolo.computeBoundingBoxes(features: [features, features, features])
            showOnMainThread(boundingBoxes)
        }
    }
    
    func showOnMainThread(_ boundingBoxes: [YOLO.Prediction]) {
        DispatchQueue.main.async {
            self.getResult(predictions: boundingBoxes)
            self.currentbuffer = nil
        }
    }
    
    func getResult(predictions: [YOLO.Prediction]) {
        for i in 0..<YOLO.maxBoundingBoxes {
            if i < predictions.count {
                
                // 修正預測框 (影像辨識模組輸入為 416 * 416)
                let prediction = predictions[i]
                let width = view.bounds.width
                let height = view.bounds.height
                let scaleX = width / CGFloat(YOLO.inputWidth)
                let scaleY = height / CGFloat(YOLO.inputHeight)
                // let top = (view.bounds.height - height) / 2
                
                var rect = prediction.rect
                rect.origin.x *= scaleX
                rect.origin.y *= scaleY
                // rect.origin.y += top
                rect.size.width *= scaleX
                rect.size.height *= scaleY
                
                // Show the bounding box.
                print("Index = \(prediction.classIndex)")
                let color = colors[prediction.classIndex]
                let label = labels[prediction.classIndex]
                let boundingBox = drawBoundingBox(frame: rect, color: color)
                boundingBoxArray.append(boundingBox)
                predictLabelArray.append(label)
            }
        }
    }
    
    func drawBoundingBox(frame: CGRect, color: UIColor) -> CAShapeLayer{
        let boundingBox = CAShapeLayer()
        boundingBox.fillColor = UIColor.clear.cgColor
        boundingBox.lineWidth = 4
        
        let path = UIBezierPath(rect: frame)
        boundingBox.path = path.cgPath
        boundingBox.strokeColor = color.cgColor
        boundingBox.isHidden = false
        
        sceneView.layer.addSublayer(boundingBox)
        
        return boundingBox
    }
    
    var touchPosition: CGPoint!
    var target = 0
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        var overlappedIndex: [Int] = []
        labelNodeOnScreen.removeFromParentNode()
        starNodeOnScreen.removeFromParentNode()
        touchPosition = gestureRecognize.location(in: sceneView)
        for i in 0..<boundingBoxArray.count{
            if boundingBoxArray[i].path!.contains(touchPosition){
                target = i
                overlappedIndex.append(i)
                print(predictLabelArray[i])
            }
        }
        if overlappedIndex.count > 1{
            target = getNear(overlappedIndex: overlappedIndex)
        }
        
        // 點擊框外
        if overlappedIndex.count == 0{
            toQAButton.isHidden = true
            toQAButton.isEnabled = false
        }
        else{
            print(predictLabelArray)
            print("Target = \(target), PredictionLabel = \(predictLabelArray[target])")
            tappedPredictionLabel = predictLabelArray[target]
            
            let arHitTestResults = sceneView.hitTest(touchPosition, types: .featurePoint) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
            if !arHitTestResults.isEmpty{
                let closestResult = arHitTestResults.first
                
                // Get Coordinates of HitTest
                let transform : matrix_float4x4 = closestResult!.worldTransform
                let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                
                difficulty = difficultyOfLabels[tappedPredictionLabel]
                
                //boundingBoxArray[target].isHidden = true
                // Create 3D Text
                let labelNode : SCNNode = createNewBubbleParentNode(tappedPredictionLabel)
                labelNode.position = worldCoord
                labelNodeOnScreen.removeFromParentNode()
                labelNodeOnScreen = labelNode
                sceneView.scene.rootNode.addChildNode(labelNodeOnScreen)
                // Create star
                let starNode: SCNNode = createStar()
                starNode.position = SCNVector3Make(transform.columns.3.x + 0.01, transform.columns.3.y - 0.03, transform.columns.3.z)
                starNodeOnScreen.removeFromParentNode()
                starNodeOnScreen = starNode
                sceneView.scene.rootNode.addChildNode(starNodeOnScreen)
                
                //旋轉
                let action = SCNAction.rotate(by: .pi * 2, around: SCNVector3(0,1,0), duration: 10.0)
                let actionLoop = SCNAction.repeatForever(action)
                starNodeOnScreen.runAction(actionLoop)
                toQAButton.isHidden = false
                toQAButton.isEnabled = true
            }
            else{
                print("No hit Result")
            }
            
        }
        
        
    }
    
    func getNear(overlappedIndex: [Int]) -> Int{
        /*
        var nearestRange = sqrt(pow(touchPosition.x - boundingBoxArray[satisfiedIndex[0]].path!.boundingBox.minX, 2) + pow(touchPosition.y - boundingBoxArray[satisfiedIndex[0]].path!.boundingBox.minY, 2))
        var nearestIndex = satisfiedIndex[0]
        for i in 1..<satisfiedIndex.count{
            let range = sqrt(pow(touchPosition.x - boundingBoxArray[satisfiedIndex[i]].path!.boundingBox.minX, 2) + pow(touchPosition.y - boundingBoxArray[satisfiedIndex[i]].path!.boundingBox.minY, 2))
            
            if nearestRange > range{
                nearestRange = range
                nearestIndex = satisfiedIndex[i]
            }
        }
        */
        var nearestRange: CGFloat = CGFloat(MAXFLOAT)
        var nearestIndex = overlappedIndex[0]
        for i in overlappedIndex{
            let range = sqrt(pow(touchPosition.x - boundingBoxArray[i].path!.boundingBox.minX, 2) + pow(touchPosition.y - boundingBoxArray[i].path!.boundingBox.minY, 2))
            if nearestRange > range{
                nearestRange = range
                nearestIndex = i
            }
        }
        return nearestIndex
    }
    
    func createNewBubbleParentNode(_ text : String) -> SCNNode {
        // Warning: Creating 3D Text is susceptible to crashing. To reduce chances of crashing; reduce number of polygons, letters, smoothness, etc.
        
        // TEXT BILLBOARD CONSTRAINT
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // BUBBLE-TEXT
        let bubbleDepth: Float = 0.03
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        var font = UIFont(name: "Futura", size: 0.15)
        font = font?.withTraits(traits: .traitBold)
        bubble.font = font
        bubble.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        bubble.firstMaterial?.diffuse.contents = UIColor.orange
        bubble.firstMaterial?.specular.contents = UIColor.black
        bubble.firstMaterial?.isDoubleSided = true
        bubble.flatness = 0.2 // setting this too low can cause crashes.
        bubble.chamferRadius = CGFloat(bubbleDepth)
        
        // BUBBLE NODE
        let (minBound, maxBound) = bubble.boundingBox
        let bubbleNode = SCNNode(geometry: bubble)
        // Centre Node - to Centre-Bottom point
        bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, bubbleDepth / 2)
        // Reduce default text size
        bubbleNode.scale = SCNVector3Make(0.3, 0.3, 0.3)
        
        
        // BUBBLE PARENT NODE
        let bubbleNodeParent = SCNNode()
        bubbleNodeParent.addChildNode(bubbleNode)
        bubbleNodeParent.constraints = [billboardConstraint]
        
        return bubbleNodeParent
    }
    func createStar() -> SCNNode{
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        var x: CGFloat = 0.0
        let starCount = Diffucult_StarCount_Dict[difficulty]
        let path = UIBezierPath()
        for _ in 1...starCount!{
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
        let shapeDepth: Float = 0.02
        let shape = SCNShape(path: path, extrusionDepth: CGFloat(shapeDepth))
        let color = #colorLiteral(red: 0.9915831685, green: 1, blue: 0, alpha: 1)
        shape.firstMaterial?.diffuse.contents = color
        shape.firstMaterial?.specular.contents = UIColor.black
        
        
        let (minBound, maxBound) = shape.boundingBox
        let starNode = SCNNode(geometry: shape)
        starNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, shapeDepth / 2)
        starNode.scale = SCNVector3Make(0.3, 0.3, 0.3)
        
        
        // BUBBLE PARENT NODE
        let starNodeParent = SCNNode()
        starNodeParent.addChildNode(starNode)
        //starNodeParent.constraints = [billboardConstraint]
        
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
