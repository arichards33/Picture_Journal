//
//  EntryDetailViewController.swift
//  Picture Journal
//
//  Created by Alex Richards on 4/27/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var editText: UITextView!
    @IBOutlet weak var editTags: UITextView!
    @IBOutlet weak var editDate: UITextField!
    
    //MARK: - Propoerties
    let localFile = SaveEntries.shared
    let dateFormatter = DateFormatter()
    var entry: Entry!
    var entryLocationInArray: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "MMMM d, yyyy"
//        editImage.image = UIImage(data: entry.photo!)
        editDate.text = dateFormatter.string(from: entry.date!)
        editText.text = entry.text
        editTags.text = entry.tags
    }

    //MARK: - Button Actions
    @IBAction func saveEdits(_ sender: UIButton) {
        localFile.editEntry(entry: entry)
        entry.text = editText.text
        entry.date = dateFormatter.date(from: editDate.text!)
        entry.tags = editTags.text
        entry.photoURL = entry.photoURL
        entry.lat = entry.lat
        entry.long = entry.long
//        entry.photo = entry.photo
        entry.currentTemp = entry.currentTemp
        do {
            let writeable = try JSONEncoder().encode(entry)
            localFile.writeToFile(entry: writeable)
            
        } catch let error as NSError {
            print(error)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelEdits(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteEntry(_ sender: UIButton) {
        localFile.editEntry(entry: entry)
        self.dismiss(animated: true, completion: nil)
    }
}
