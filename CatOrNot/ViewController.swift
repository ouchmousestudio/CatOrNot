//
//  ViewController.swift
//  SeeFood
//
//  Created by Miles Fearnall-Williams on 2019/08/30.
//  Copyright © 2019 Miles Fearnall-Williams. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var cameraImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    //Image Text
    @IBOutlet weak var imageText: UILabel!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cameraImageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CI Image")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            //If it's a cat or not
            
            if let firstResult = results.first {
                let parts = firstResult.identifier.components(separatedBy: ", ")
                if firstResult.identifier.contains("cat") {
                    //Change Nav title
                self.navigationItem.title = "It's a Cat!"
                    //Change text box
                    self.imageText.text = ""
            }  else {
                    self.navigationItem.title = "It's not a Cat!"
                    self.imageText.text = "...It's a " + parts[0]
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
        try handler.perform([request])
        }
        catch {
            print(error)
        }

        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

