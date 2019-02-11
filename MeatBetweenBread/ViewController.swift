//
//  ViewController.swift
//  MeatBetweenBread
//
//  Created by Dylan Rothfeld on 2/10/19.
//  Copyright © 2019 Dylan Rothfeld. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO

class ViewController: UIViewController {

    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var ClassificationLabel: UILabel!
    @IBOutlet weak var Toolbar: UIToolbar!
    @IBOutlet weak var SelectImageToolbarButton: UIBarButtonItem!
    @IBOutlet weak var SaveImageToolbarButton: UIBarButtonItem!
    @IBOutlet weak var OpenCameraButton: UIButton!
    @IBOutlet weak var UntouchedMessageLabel: UILabel!
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // Get ML model
            let model = try VNCoreMLModel(for: SandwichOrBurgerClassifier().model)
            
            // Make request to process image with model
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassification(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load machine learning model: \(error)")
        }
    }()
    
    func processClassification(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            
            // Classification result is a failure
            guard let results = request.results else {
                self.ClassificationLabel.text = "Error"
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
            
            // Classification is not recognized
            if classifications.isEmpty {
                self.ClassificationLabel.text = "Unknown"
            }
                
                // Display classification outcome
            else {
                // Format classification results
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    return String(format: "%@ (%.2f)", classification.identifier, classification.confidence)
                }
                
                // Display the higher confidence classificaiton outcome
                self.ClassificationLabel.minimumScaleFactor = 0.10
                self.ClassificationLabel.adjustsFontSizeToFitWidth = true
                self.ClassificationLabel.text = descriptions[0]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func CameraButtonPressed(_ sender: Any) {
    }
    
    @IBAction func SelectImageButtonPressed(_ sender: Any) {
    }
    
    @IBAction func SaveImageButtonPressed(_ sender: Any) {
    }
    
}

