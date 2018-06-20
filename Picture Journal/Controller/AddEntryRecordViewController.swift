//
//  AddEntryRecordViewController.swift
//  Picture Journal
//
//  Created by Alex Richards on 4/29/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import UIKit
import ImageIO
import Vision


class AddEntryRecordViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var entryTags: UITextView!
    @IBOutlet weak var entryText: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: - Properties
    let ckManager = CloudKitManager.shared
    let writeableFile = SaveEntries.shared
    let NetworkingManager = Networking.shared
    var entry = Entry()
    
    var imageLat:  Double!
    var imageLong: Double!
    var imageDate: Date!
    var tags: String?
    var entryWeather: Weather?
    var imageURL: URL!
    var imageRealURL: URL!
    var image: UIImage!
    
    var pictureCount = 0
    var defaults: UserDefaults = UserDefaults()
    let urlString = "https://api.darksky.net/forecast/341c9693700cd2a05856912116172d69/"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedImage.image = image
        getLocation(dict: getImageData())
        getDate(dict: getImageData())
        saveImageFile()
        
        
        guard let ciImage = CIImage(image: image!) else {
            fatalError("Not able to convert UIImage to CIImage")
        }
        
        detectObjects(image: ciImage)
        checkWeather(lat: imageLat, long: imageLong, time: imageDate)
        
    }
    
    //MARK: - Button Actions
    @IBAction func saveEntry(_ sender: Any) {
        
        entry.text = entryText.text
        entry.photoURL = imageRealURL.path
        entry.date = imageDate
        entry.lat = imageLat
        entry.long = imageLong
//        entry.photo = image
        entry.tags = entryTags.text
        entry.currentTemp = Int((entryWeather?.currently?.temperature)!)
    
        ckManager.saveEntry(entry: entry)
        do {
            let writeable = try JSONEncoder().encode(entry)
            writeableFile.writeToFile(entry: writeable)
            
        } catch let error as NSError {
            print(error)
        }
        
        ckManager.getEntryByURL(entry: entry)
        performSegue(withIdentifier: "Unwind", sender: self)
    }
    
    @IBAction func cancelEntry(_ sender: Any) {
        performSegue(withIdentifier: "Unwind", sender: self)
    }
    
    //MARK: - Collect Entry Data
    func getImageData() -> [String: Any]{
        var dict: [String: Any] = [:]
        if let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) {
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
            dict = (imageProperties as? [String: Any])!
        }
        return dict
    }
    
    func getLocation(dict: [String: Any]) {
        print("GETTING LOCATION DATA")
        let locationData = dict["{GPS}"] as! [String : Any]
        imageLat = locationData["Latitude"] as! Double
        imageLong = locationData["Longitude"] as! Double
    }
    
    func getDate(dict: [String: Any]) {
        print("GETTING DATE")
        let dateData = dict["{TIFF}"] as! [String: Any]
        let dateString = dateData["DateTime"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        imageDate = dateFormatter.date(from: dateString)
    }
    
    func detectObjects(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: MobileNet().model) else {
            fatalError("Can't load the ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Unexpected result type from VNCoreMLRequest")
            }
            
            var tags = ""
            for result in results[0...5] {
                tags += "\(result.identifier) "
            }
            
            DispatchQueue.main.async {
                self.entryTags.text = tags
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    
    func saveImageFile(){

        let localFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(entry.uuid).png")
        let imageData = UIImagePNGRepresentation(image)

        do {
            try imageData?.write(to: localFile)
            imageRealURL = localFile
            
        } catch let error as NSError {
            print(error)
        }
    }

    func checkWeather(lat: Double, long: Double, time: Date) {
        let timeNeeded = Int(time.timeIntervalSince1970)
        let append = "\(lat),\(long),\(timeNeeded)"
        let finalURL = urlString + append
        
        NetworkingManager.getWeather(url: finalURL) {(returned) in
            if let data = returned {
                self.entryWeather = data
            }
        }
    }
}
