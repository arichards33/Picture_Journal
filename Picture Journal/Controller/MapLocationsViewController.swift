//
//  MapLocationsViewController.swift
//  Picture Journal
//
//  Created by Alex Richards on 5/1/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class MapLocationsViewController: UIViewController, MKMapViewDelegate {

    //MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Properties
    var entriesToMap: [Entry] = []
    var mappableEntries: [MapEntries] = []
    let localFile = SaveEntries.shared

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if localFile.checkForFile() {
            let arrayFromFile = localFile.readFromFile()
            for entry in arrayFromFile{
                do {
                    let entryDecoded = try JSONDecoder().decode(Entry.self, from: entry as! Data)
                    entriesToMap.append(entryDecoded)
                    
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        createMappable()
        mapView.delegate = self
        mapView.addAnnotations(mappableEntries)
    }
    
    //MARK: - MapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.isKind(of: MapEntries.self) else {
            return nil
        }
        
        let annoIdent = "Entry"
        var annoView = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdent)
        
        if annoView == nil  {
            annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Entry")
            annoView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annoView?.canShowCallout = true
        } else {
            annoView?.annotation = annotation
        }
        
        annoView?.image = #imageLiteral(resourceName: "Image-2")
        
        return annoView
    }
    
    func createMappable(){
        for entry in entriesToMap{
            let coord = CLLocationCoordinate2D(latitude: entry.lat!, longitude: entry.long!)
            let mappable = MapEntries(coordinate: coord, title: entry.text!)
            mappableEntries.append(mappable)
        }
    }
}


