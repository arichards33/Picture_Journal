//
//  AddPhotoViewController.swift
//  Picture Journal
//
//  Created by Alex Richards on 4/27/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import UIKit
import CloudKit


class AddPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - Properties
    let photoPicker = UIImagePickerController()
    
    typealias ImageData = (url: URL, image: UIImage)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoPicker.delegate = self
        photoPicker.allowsEditing = false
        photoPicker.sourceType = .photoLibrary
        photoPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(photoPicker, animated: true, completion: nil)
    }
    
    //MARK: - ImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("picked a photo")
        
        let imageURL = info[UIImagePickerControllerImageURL] as! URL
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let senderInfo: ImageData = (url: imageURL, image: image)
        photoPicker.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "AddText", sender: senderInfo)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddText" {
            let vc = segue.destination as! AddEntryRecordViewController
            let imageInfo: ImageData = sender as! ImageData
            vc.imageURL = imageInfo.url
            vc.image = imageInfo.image
        }
    }
}
