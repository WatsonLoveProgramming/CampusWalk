//
//  InfoViewController.swift
//  CampusWalk
//
//  Created by Watson Li on 10/22/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

protocol InfoDelegate {
    func okClicked()
}

class InfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var buildingTitle: UILabel!
    @IBOutlet weak var buildingImage: UIImageView!
    let mapModel = MapModel.sharedInstance
    var name: String?
    var image: UIImage?
    var delegate: InfoDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buildingTitle.text = name
        buildingImage.image = image
        buildingImage.contentMode = .scaleAspectFit
        buildingImage.isUserInteractionEnabled = true
    }

    func configureInfo(name:String, image: UIImage) {
        self.name = name
        self.image = image
    }
    
    @IBAction func dismissMe(_ sender: Any) {
        if let delegate = delegate {
            delegate.okClicked()
        }
    }
    
    @IBAction func modifyImage(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Choose an image", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "From photos album", style: .default) { (action:UIAlertAction)  in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true)
            }else{
                let alert = UIAlertController(title: "Photos album not available", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancel)
                self.present(alert, animated: true)
            }
            
        }
        let action2 = UIAlertAction(title: "Take a new one", style: .default) { (action:UIAlertAction)  in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true)
            }else{
                let alert = UIAlertController(title: "Camera not available", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancel)
                self.present(alert, animated: true)
            }
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        self.present(actionSheet, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        mapModel.userImages[name!] = selectedImage
        // Set photoImageView to display the selected image.
        buildingImage.image = selectedImage
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
}
