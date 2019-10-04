import Foundation
import UIKit
import CoreML
import Accelerate

//let labels = ["raccoon"]
//let difficultyOfLabels: [String:String] = ["raccoon": "Normal"]
let labels = [
    "butterfly",
    "bicycle",
    "book",
    "bottle",
    "bus",
    "car",
    "cat",
    "cellphone",
    "sparrow",
    "dog",
    "motorcycle",
    "laptop",
    "headphone",
    "keyboard",
    "screen",
    "mouse",
    "pen",
    "glasses",
    "light",
    "tree",
    "flower",
    "duck",
    "cicada",
    "Sciuridae",
    "Gorsachius melanolophus",
    "turtle"
]

let difficultyOfLabels: [String:String] =  [
    "butterfly": "Normal",
    "bicycle": "Hard",
    "book": "Normal",
    "bottle": "Normal",
    "bus": "Easy",
    "car": "Hard",
    "cat": "Hard",
    "cellphone": "Normal",
    "sparrow": "Normal",
    "dog": "Hard",
    "motorcycle": "Hard",
    "laptop": "Hard",
    "headphone": "Easy",
    "keyboard": "Easy",
    "screen": "Easy",
    "mouse": "Easy",
    "pen": "Normal",
    "glasses": "Easy",
    "light": "Easy",
    "tree": "Easy",
    "flower": "Easy",
    "duck": "Hard",
    "cicada": "Normal",
    "Sciuridae": "Easy",
    "Gorsachius melanolophus": "Normal",
    "turtle": "Normal"
]

/*
let labelTableMap = [
    "butterfly": "animal",
    "bicycle": "transportation",
    "book": "daily",
    "bottle": "daily",
    "bus": "transportation",
    "car": "transportation",
    "cat": "animal",
    "cellphone": "electronic",
    "sparrow": "animal",
    "dog": "animal",
    "motorcycle": "transportation",
    "laptop": "electronic",
    "headphone": "electronic",
    "keyboard": "electronic",
    "screen": "electronic",
    "mouse": "electronic",
    "pen": "daily",
    "glasses": "daily",
    "light": "daily",
    "tree": "plant",
    "flower": "plant",
    "duck": "animal",
    "cicada": "animal",
    "Sciuridae": "animal",
    "Gorsachius melanolophus": "animal",
    "turtle": "animal"
]
 */
/*
// The labels for the 80 classes.
let labels = [
    "person",
    "bicycle",
    "car",
    "motorbike",
    "aeroplane",
    "bus",
    "train",
    "truck",
    "boat",
    "traffic light",
    "fire hydrant",
    "stop sign",
    "parking meter",
    "bench",
    "bird",
    "cat",
    "dog",
    "horse",
    "sheep",
    "cow",
    "elephant",
    "bear",
    "zebra",
    "giraffe",
    "backpack",
    "umbrella",
    "handbag",
    "tie",
    "suitcase",
    "frisbee",
    "skis",
    "snowboard",
    "sports ball",
    "kite",
    "baseball bat",
    "baseball glove",
    "skateboard",
    "surfboard",
    "tennis racket",
    "bottle",
    "wine glass",
    "cup",
    "fork",
    "knife",
    "spoon",
    "bowl",
    "banana",
    "apple",
    "sandwich",
    "orange",
    "broccoli",
    "carrot",
    "hot dog",
    "pizza",
    "donut",
    "cake",
    "chair",
    "sofa",
    "pottedplant",
    "bed",
    "diningtable",
    "toilet",
    "tvmonitor",
    "laptop",
    "mouse",
    "remote",
    "keyboard",
    "cell phone",
    "microwave",
    "oven",
    "toaster",
    "sink",
    "refrigerator",
    "book",
    "clock",
    "vase",
    "scissors",
    "teddy bear",
    "hair drier",
    "toothbrush"
]

let difficultyOfLabels: [String:String] =  [
    "person": "Easy",
    "bicycle": "Normal",
    "car": "Normal",
    "motorbike": "Easy",
    "aeroplane": "Hard",
    "bus": "Normal",
    "train": "Easy",
    "truck": "Normal",
    "boat": "Normal",
    "traffic light": "Easy",
    "fire hydrant": "Hard",
    "stop sign": "Easy",
    "parking meter": "Easy",
    "bench": "Easy",
    "bird": "Easy",
    "cat": "Easy",
    "dog": "Easy",
    "horse": "Easy",
    "sheep": "Normal",
    "cow": "Normal",
    "elephant": "Easy",
    "bear": "Normal",
    "zebra": "Normal",
    "giraffe": "Easy",
    "backpack": "Normal",
    "umbrella": "Easy",
    "handbag": "Normal",
    "tie": "Easy",
    "suitcase": "Normal",
    "frisbee": "Normal",
    "skis": "Normal",
    "snowboard": "Hard",
    "sports ball": "Normal",
    "kite": "Normal",
    "baseball bat": "Normal",
    "baseball glove": "Normal",
    "skateboard": "Normal",
    "surfboard": "Normal",
    "tennis racket":"Easy",
    "bottle": "Easy",
    "wine glass":"Easy",
    "cup": "Normal",
    "fork": "Easy",
    "knife": "Easy",
    "spoon": "Easy",
    "bowl": "Easy",
    "banana": "Easy",
    "apple": "Normal",
    "sandwich": "Easy",
    "orange": "Easy",
    "broccoli": "Easy",
    "carrot": "Easy",
    "hot dog": "Easy",
    "pizza": "Easy",
    "donut": "Easy",
    "cake": "Easy",
    "chair": "Easy",
    "sofa": "Easy",
    "pottedplant": "Hard",
    "bed": "Normal",
    "diningtable": "Normal",
    "toilet": "Normal",
    "tvmonitor": "Hard",
    "laptop": "Hard",
    "mouse": "Hard",
    "remote": "Hard",
    "keyboard": "Normal",
    "cell phone": "Hard",
    "microwave": "Hard",
    "oven": "Normal",
    "toaster": "Normal",
    "sink": "Normal",
    "refrigerator": "Hard",
    "book": "Normal",
    "clock": "Normal",
    "vase": "Normal",
    "scissors": "Normal",
    "teddy bear": "Normal",
    "hair drier": "Normal",
    "toothbrush": "Hard",
]
*/
// anchor boxes
let anchors: [[Float]] = [[116,90,  156,198,  373,326], [30,61,  62,45,  59,119], [10,13,  16,30,  33,23]]

/**
  Removes bounding boxes that overlap too much with other boxes that have
  a higher score.

  Based on code from https://github.com/tensorflow/tensorflow/blob/master/tensorflow/core/kernels/non_max_suppression_op.cc

  - Parameters:
    - boxes: an array of bounding boxes and their scores
    - limit: the maximum number of boxes that will be selected
    - threshold: used to decide whether boxes overlap too much
*/
func nonMaxSuppression(boxes: [YOLO.Prediction], limit: Int, threshold: Float) -> [YOLO.Prediction] {

  // Do an argsort on the confidence scores, from high to low.
  let sortedIndices = boxes.indices.sorted { boxes[$0].score > boxes[$1].score }

  var selected: [YOLO.Prediction] = []
  var active = [Bool](repeating: true, count: boxes.count)
  var numActive = active.count

  // The algorithm is simple: Start with the box that has the highest score.
  // Remove any remaining boxes that overlap it more than the given threshold
  // amount. If there are any boxes left (i.e. these did not overlap with any
  // previous boxes), then repeat this procedure, until no more boxes remain
  // or the limit has been reached.
  outer: for i in 0..<boxes.count {
    if active[i] {
      let boxA = boxes[sortedIndices[i]]
      selected.append(boxA)
      if selected.count >= limit { break }

      for j in i+1..<boxes.count {
        if active[j] {
          let boxB = boxes[sortedIndices[j]]
          if IOU(a: boxA.rect, b: boxB.rect) > threshold {
            active[j] = false
            numActive -= 1
            if numActive <= 0 { break outer }
          }
        }
      }
    }
  }
  return selected
}

/**
  Computes intersection-over-union overlap between two bounding boxes.
*/
public func IOU(a: CGRect, b: CGRect) -> Float {
  let areaA = a.width * a.height
  if areaA <= 0 { return 0 }

  let areaB = b.width * b.height
  if areaB <= 0 { return 0 }

  let intersectionMinX = max(a.minX, b.minX)
  let intersectionMinY = max(a.minY, b.minY)
  let intersectionMaxX = min(a.maxX, b.maxX)
  let intersectionMaxY = min(a.maxY, b.maxY)
  let intersectionArea = max(intersectionMaxY - intersectionMinY, 0) *
                         max(intersectionMaxX - intersectionMinX, 0)
  return Float(intersectionArea / (areaA + areaB - intersectionArea))
}

extension Array where Element: Comparable {
  /**
    Returns the index and value of the largest element in the array.
  */
  public func argmax() -> (Int, Element) {
    precondition(self.count > 0)
    var maxIndex = 0
    var maxValue = self[0]
    for i in 1..<self.count {
      if self[i] > maxValue {
        maxValue = self[i]
        maxIndex = i
      }
    }
    return (maxIndex, maxValue)
  }
}

/**
  Logistic sigmoid.
*/
public func sigmoid(_ x: Float) -> Float {
  return 1 / (1 + exp(-x))
}

/**
  Computes the "softmax" function over an array.

  Based on code from https://github.com/nikolaypavlov/MLPNeuralNet/

  This is what softmax looks like in "pseudocode" (actually using Python
  and numpy):

      x -= np.max(x)
      exp_scores = np.exp(x)
      softmax = exp_scores / np.sum(exp_scores)

  First we shift the values of x so that the highest value in the array is 0.
  This ensures numerical stability with the exponents, so they don't blow up.
*/
public func softmax(_ x: [Float]) -> [Float] {
  var x = x
  let len = vDSP_Length(x.count)

  // Find the maximum value in the input array.
  var max: Float = 0
  vDSP_maxv(x, 1, &max, len)

  // Subtract the maximum from all the elements in the array.
  // Now the highest value in the array is 0.
  max = -max
  vDSP_vsadd(x, 1, &max, &x, 1, len)

  // Exponentiate all the elements in the array.
  var count = Int32(x.count)
  vvexpf(&x, x, &count)

  // Compute the sum of all exponentiated values.
  var sum: Float = 0
  vDSP_sve(x, 1, &sum, len)

  // Divide each element by the sum. This normalizes the array contents
  // so that they all add up to 1.
  vDSP_vsdiv(x, 1, &sum, &x, 1, len)

  return x
}
