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
    
    func updateClassification(for image: UIImage) {
        ClassificationLabel.text = "Processing..."
        ClassificationLabel.isHidden = false
        UntouchedMessageLabel.isHidden = true
        SaveImageToolbarButton.isEnabled = true
        
        // Attempt to create CIImage for processing
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }
        
        // Make a classification request to process the image
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            }
                
                // Handler that attempts to catch general image processing errors
            catch {
                print("Failed to perform classification. \n\(error.localizedDescription)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func CameraButtonPressed(_ sender: Any) {
        // If the camera view is not available, show the photolibrary instead
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        self.presentPhotoPicker(sourceType: .camera)
    }
    
    @IBAction func SelectImageButtonPressed(_ sender: Any) {
        self.presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    @IBAction func SaveImageButtonPressed(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(ImageView.image!, self, #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
        SaveImageToolbarButton.isEnabled = false
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    @objc func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // Error when trying to save image
        if let error = error {
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alertController, animated: true)
            
            // Successfully saved image
        } else {
            let alertController = UIAlertController(title: "Saved", message: "The image has been saved to your photos.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alertController, animated: true)
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Handles image picker selection
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Handle the chosen image from the UIImage picker
        picker.dismiss(animated: true)
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        ImageView.image = selectedImage
        updateClassification(for: selectedImage)
    }
}

