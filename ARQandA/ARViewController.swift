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
    
    
    var boundingBoxes = [BoundingBox]()
    
    let visionQueue = DispatchQueue(label: "visionQueue")
    
    
    var currentBuffer: CVPixelBuffer?
    
    var score = UILabel()
    // Default device == iPhone
    var scoreWidth = 70
    var scoreHeight = 70
    var buttonWidth = 45
    var buttonHeight = 45
    var objectInfoWidth = 220
    var objectInfoHeight = 70
    
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
        setUpScore()
        setUpBackBtn()
        setUpBoundingBoxes()
        setUpVision()
        
        
        for box in self.boundingBoxes {
            box.addToLayer(self.sceneView.layer)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        score.text = "\(getScore())"
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
    
    fileprivate func setUpScore() {
        // Set up score
        // If device == iPad
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
            scoreWidth = 120
            scoreHeight = 120
            buttonWidth = 70
            buttonHeight = 70
            objectInfoWidth = 300
            objectInfoHeight = 100
            backButtonWidth = 120
            backButtonHeight = 120
        }
        
        score = UILabel(frame: CGRect(x: Int(UIScreen.main.bounds.width) - scoreWidth - 10 , y: 50, width: scoreWidth , height: scoreHeight))
        score.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        score.textColor = UIColor(white: 1, alpha: 1)
        score.font = UIFont(name: "AthensClassic", size: CGFloat(scoreWidth / 2 + 10))
        score.textAlignment = .center
        score.layer.masksToBounds = true
        score.layer.cornerRadius = score.bounds.width / 2
        score.layer.zPosition = 1;
        view.addSubview(score)
    }
    
    func getScore() -> Int{
        return UserDefaults.standard.integer(forKey: "right")
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
        backButton.layer.zPosition = 1;
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
        print("\(rotation.z)")
        
        
        guard currentBuffer == nil else{ return }
        
        visionQueue.async {
            if self.DeviceMoving() == true && rotation.z >= -2.2 && rotation.z <= -0.8 {
                self.updatePosition()
                self.currentBuffer = frame.capturedImage
                self.predictUsingVision(pixelBuffer: self.currentBuffer!)
            }
        }
        
        //print("-----------------")
        
    }
    
    func DeviceMoving() -> Bool{
        if abs(self.pre_MoveX - self.new_MoveX) > 0.01{
            return true;
        }
        if abs(self.pre_MoveY - self.new_MoveY) > 0.01{
            return true;
        }
        if abs(self.pre_MoveZ - self.new_MoveZ) > 0.01{
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
    
    private var label = ""
    private var Difficult_Number_Dict  = ["Easy" : "3",
                                          "Normal": "5",
                                          "Hard": "7"]
    
    private var numberOfQuestionToSend = ""
    
    func show(predictions: [YOLO.Prediction]) {
        for i in 0..<boundingBoxes.count {
            //boundingBoxes[i].hide(
            if i < predictions.count {
                let prediction = predictions[i]
                
                let rect = scaledRect(rect: prediction.rect)
                
                // Perdicted result
                label = labels[prediction.classIndex]
                let d = difficulty[label]!
                let n = Difficult_Number_Dict[d]!
                
                //let confidence = prediction.score * 100
                //let color = colors[prediction.classIndex]
                
                
                if rect.origin.x + rect.size.width / 2 <= UIScreen.main.bounds.width {
                    boundingBoxes[i].show(frame: rect, label: label, difficulty: d)
                    addButton(frame: CGRect(x:rect.origin.x + 5, y: rect.origin.y + 5, width: CGFloat(buttonWidth), height: CGFloat(buttonHeight)),
                              label:label,
                              numberOfQuestion: n, indexOfObject: i)
                    
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
        //newRect.size.width *= scaleX
        //newRect.size.height *= scaleY
        newRect.size.width = CGFloat(objectInfoWidth)
        newRect.size.height = CGFloat(objectInfoHeight)
        
        
        if newRect.origin.x < 0.0 {
            newRect.origin.x = 0.0
        }
        if newRect.origin.y < 0.0{
            newRect.origin.y = 0.0
        }
        
        if newRect.origin.y <= 50 + backButton.bounds.height{
            if (newRect.origin.x <=  15 + backButton.bounds.width) || (newRect.origin.x >= UIScreen.main.bounds.width - CGFloat(scoreWidth) - 10)
            {
                newRect.origin.y = 50 + backButton.bounds.height
            }
        }
        /*
         if newRect.origin.x + newRect.size.width > UIScreen.main.bounds.width{
         newRect.size.width = UIScreen.main.bounds.width - newRect.origin.x
         }
         if newRect.origin.y + newRect.size.height > UIScreen.main.bounds.height{
         newRect.size.height = UIScreen.main.bounds.height - newRect.origin.y
         }
         */
        return newRect
    }
    
    var button: MyButton!
    
    // Create button programmtically
    func addButton(frame:CGRect,label: String, numberOfQuestion:String, indexOfObject: Int){
        
        button = MyButton(frame: frame, label: label, numberOfQuestion: numberOfQuestion, indexOfObject: indexOfObject)
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
    
    @objc func buttonAction(sender: MyButton!){
        label = sender.label
        numberOfQuestionToSend = sender.numberOfQuestion
        boundingBoxes[sender.indexOfObject].hide()
        self.performSegue(withIdentifier: "switchScene", sender: self)
        sender.removeFromSuperview()
    }
    
    // Send the selected object name and the number of question to start Q&A
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? QAViewController{
            dest.label = self.label
            dest.numberOfQuestion = self.numberOfQuestionToSend
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
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


class MyButton: UIButton{
    var label: String!
    var numberOfQuestion: String!
    var indexOfObject: Int!
    
    init(frame: CGRect, label: String, numberOfQuestion: String, indexOfObject: Int) {
        super.init(frame: frame)
        
        self.label = label
        self.numberOfQuestion = numberOfQuestion
        self.indexOfObject = indexOfObject
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

