 //
//  MainTableViewController.swift
//  Picture Journal
//
//  Created by Alex Richards on 4/26/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import UIKit
import CloudKit

class MainTableViewController: UITableViewController, UISearchBarDelegate {
    
    //MARK: - Properties
    let ckManager = CloudKitManager.shared
    let localFile = SaveEntries.shared
    
    var entryArray: [Entry] = []
    let formatter = DateFormatter()
    var allMonths: [String: Int] = [:]
    var cellArray: [Entry] = []
    var selectedEntries = [Int: [Entry]]()
    let searchBar = UISearchBar()
    var filteredData = [Entry]()
    var isSearching = false
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        entryArray = []
        cellArray = []
        allMonths = [:]
        
        if localFile.checkForFile() {
            let arrayFromFile = localFile.readFromFile()
            for entry in arrayFromFile{
                do {
                    var entryDecoded = try JSONDecoder().decode(Entry.self, from: entry as! Data)
                    entryDecoded.arrayIndex = entryArray.count
                    entryDateMonth(date: entryDecoded.date!)
                    entryArray.append(entryDecoded)
                    cellArray.append(entryDecoded)
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        ckManager.getEntries()
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        }
        return allMonths.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        }
        return Array(allMonths)[section].value
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Entry", for: indexPath) as! MainTableViewCell
        let dateFormatter = DateFormatter()
        
        if isSearching {
            for cellOption in filteredData {
                dateFormatter.dateFormat = "MMMM d, yyyy"
                let image = UIImage(contentsOfFile: cellOption.photoURL!)
                cell.entryImage.image = image
                cell.imageText?.text = cellOption.text
                cell.dateLabel.text = dateFormatter.string(from: cellOption.date!)
                if cellOption.currentTemp != nil {
                    let temp = Int((cellOption.currentTemp)!)
                    cell.weather.text = "Temp: \(temp)"
                }
                return cell
            }
        } else {
            
            dateFormatter.dateFormat = "MMMM"
            var count = 0
            
            for cellOption in cellArray{
                if Array(allMonths)[indexPath.section].key == dateFormatter.string(from: cellOption.date!){
                    dateFormatter.dateFormat = "MMMM d, yyyy"
                    let imageFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(cellOption.uuid).png")
                    
                    do {
                        let imageData = try Data(contentsOf: imageFile)
                        cell.entryImage.image = UIImage(data: imageData)
                    }  catch let error as NSError {
                        print(error)
                    }
                    
                    cell.imageText?.text = cellOption.text
                    cell.dateLabel.text = dateFormatter.string(from: cellOption.date!)
                    
                    if cellOption.currentTemp != nil {
                        let temp = Int((cellOption.currentTemp)!)
                        cell.weather.text = "Temp: \(temp)"
                    }
                    
                    cellArray.remove(at: count)
                    var sectionEntries = Array(selectedEntries)[indexPath.section].value
                    sectionEntries.append(cellOption)
                    selectedEntries[indexPath.section] = sectionEntries
                    
                    return cell
                } else {
                    count += 1
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sectionEntries = Array(selectedEntries)[indexPath.section].value
        let entrySelected = sectionEntries[indexPath.item]
        self.performSegue(withIdentifier: "EditEntry", sender: entrySelected)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(allMonths)[section].key
    }
    
    func entryDateMonth(date: Date) {
        var alreadyCounted = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: date)
        
        for (section, count) in allMonths {
            if section == month {
                alreadyCounted = true
                allMonths[section] = count + 1
            }
        }
        if !alreadyCounted {
            allMonths[month] = 1
            selectedEntries[allMonths.count - 1] = []
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEntry"{
            let svc = segue.destination as! EntryDetailViewController
            svc.entry = sender as! Entry
        }
        if segue.identifier == "Map" {
            let svc = segue.destination as! MapLocationsViewController
            svc.entriesToMap = entryArray
        }
    }
    
    //MARK: - Search Bar
    func createSearchBar() {
        searchBar.sizeToFit()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        self.navigationItem.titleView = searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            for entry in entryArray{
                if searchBar.text == entry.tags  {
                    filteredData.append(entry) }
                tableView.reloadData()
            }
        }
    }
    
    //MARK: - Button Actions
    @IBAction func goToMaps(_ sender: Any) {
        self.performSegue(withIdentifier: "Map", sender: sender)
    }
    
    @IBAction func unwindFromEntryAdd(segue:UIStoryboardSegue) { }
}
