//
//  ViewController.swift
//  Virtual TOurists
//
//  Created by Amarnath Manipatra on 14/05/17.
//  Copyright © 2017 otd. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController
{
    
    
    @IBOutlet weak var mapView: MKMapView!
    enum PresentationState { case configure, on, off }
    
    var presentationState: Bool!
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.latitude, ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        fetchedResultsController?.delegate = self
        loadPersistedRegion()
        setPersistedLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupGesture()
    }
    
    
}


extension ViewController: NSFetchedResultsControllerDelegate
{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {}
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {}
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}
}

extension ViewController :MKMapViewDelegate
{
    func setupGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(action))
        longPress.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPress)
    }
    func action(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .ended {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = Pin(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude, context: AppDelegate.stack.context)
            performUIUpdatesOnMain {
                self.mapView.addAnnotation(annotation)
            }
            AppDelegate.stack.save()
        }
    }
}

extension ViewController :CLLocationManagerDelegate
{
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let error as NSError {
                print("Error while trying to perform a search: \n\(error)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
    func loadPersistedRegion() {
        if let region = UserDefaults.standard.object(forKey: Constants.region) as AnyObject? {
            let latitude = region[Constants.latitude] as! CLLocationDegrees
            let longitude = region[Constants.longitude] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let latDelta = region[Constants.latitudeDelta] as! CLLocationDegrees
            let longDelta = region[Constants.longitudeDelta] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            let updatedRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(updatedRegion, animated: true)
        }
    }
    func setPersistedLocations() {
        executeSearch()
        for pin in fetchedResultsController?.fetchedObjects as! [Pin] {
            mapView.addAnnotation(pin as MKAnnotation)
        }
    }
    
}

extension ViewController {
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.photoAlbum {
            let pin = sender as! Pin
            let nextController = segue.destination as! PhotosViewController
            nextController.pin = pin
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = ReuseID.pin
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
            pinView!.isDraggable = true
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let pin = view.annotation as! Pin
        performSegue(withIdentifier: Identifier.photoAlbum, sender: pin)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let persistedRegion = [
            Constants.latitude : mapView.region.center.latitude,
            Constants.longitude : mapView.region.center.longitude,
            Constants.latitudeDelta : mapView.region.span.latitudeDelta,
            Constants.longitudeDelta : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(persistedRegion, forKey: Constants.region)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .ending {
            let annotation = view.annotation as! Pin
            mapView.addAnnotation(annotation)
            AppDelegate.stack.save()
        }
    }
    
}




