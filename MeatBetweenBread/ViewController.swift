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

