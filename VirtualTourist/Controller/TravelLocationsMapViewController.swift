//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Ali Ahmad on 15/07/2020.
//  Copyright © 2020 Ali Ahmed. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController,MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var loadedPins:[Pin] = []
    var dataController:DataController!
    var pin :Pin = Pin()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLongPressRecongnider()
        loadSavedPins()
    }
    
    
    
    fileprivate func loadSavedPins() {
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        var annotations : [MKPointAnnotation] = []
        if let pins = try? dataController.viewContext.fetch(fetchRequest){
            for pin in pins{
                let lat = Double(pin.latitude!)
                let lon = Double(pin.longitude!)
                let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotations.append(annotation)
               
            }
            self.loadedPins = pins
            mapView.addAnnotations(annotations)
        }
    }

    
    fileprivate func setupLongPressRecongnider() {
           let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
           longPressRecogniser.minimumPressDuration = 1.0
           mapView.addGestureRecognizer(longPressRecogniser)
       }
    
    
    fileprivate func addAnnotationToMapView(_ coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
         if gestureRecognizer.state != .began { return }

        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = "\(touchMapCoordinate.latitude)"
        pin.longitude = "\(touchMapCoordinate.longitude)"
        pin.hasPhotos = false
        try? dataController.viewContext.save()
        loadedPins.append(pin)
        addAnnotationToMapView(touchMapCoordinate)
     }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           
           let reuseId = "pin"
           
           var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

           if pinView == nil {
               pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
               pinView!.canShowCallout = true
               pinView!.pinTintColor = .red
               pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
               pinView?.animatesDrop = true
           }
           else {
               pinView!.annotation = annotation
           }
        
           return pinView
       }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedPin = getPinInstance(lat: "\(view.annotation?.coordinate.latitude as! Double)", lon: "\(view.annotation?.coordinate.longitude as! Double)")
        let photoAlbumVC = storyboard?.instantiateViewController(identifier: "photoAlbumVC") as! PhotoAlbumViewController
        photoAlbumVC.pin = selectedPin
        photoAlbumVC.dataController = dataController
          self.navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
    func getPinInstance(lat:String,lon:String)->Pin?{
            for pin in loadedPins{
            if pin.latitude! == lat && pin.longitude! == lon {
               return pin
            }
        }
        return nil
        
    }
}
