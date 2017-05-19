//
//  PhotosViewController.swift
//  Virtual TOurists
//
//  Created by Amarnath Manipatra on 14/05/17.
//  Copyright © 2017 otd. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    
    var pin : Pin?
    
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.photo)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.id, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: Constants.format, self.pin!)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocation()
        executeSearch()
        
        fetchedResultsController.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        downloadCollection()
    }
    
    
    @IBAction func newCollectionTapped(_ sender: UIBarButtonItem) {
        selectedIndexes.isEmpty ? newCollection() : deleteSelectedPhotos()
    }
    
}

extension PhotosViewController : UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        print(sectionInfo.numberOfObjects)
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.photoAlbumViewCell, for: indexPath) as! PhotoCollectionViewCell
        configureCell(cell, atIndexPath: indexPath as NSIndexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        
        if let index = selectedIndexes.index(of: indexPath as NSIndexPath) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(indexPath as NSIndexPath)
        }
        
        configureCell(cell, atIndexPath: indexPath as NSIndexPath)
        
        updateButton()
    }
    
    func configureCell(_ cell: PhotoCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let photo = self.fetchedResultsController.object(at: indexPath as IndexPath) as! Photo
        let placeHolderImage = UIImage(named: ImageName.flickr)
        var cellImage = placeHolderImage
        cell.imageView.image = nil
        
        if let image = photo.photo {
            cellImage = UIImage(data: image as Data)
        } else {
            let task = FlickerClient.sharedInstance().getFlickrImages(photo) { (success, errorString, imageData) in
                if errorString != nil {
                    print(ErrorIs.configureCell)
                    cellImage = nil
                } else {
                    if let data = imageData {
                        performUIUpdatesOnMain {
                            photo.photo = data
                            cell.imageView.image = UIImage(data: data)
                        }
                    } else {
                        print(ErrorIs.getImage)
                    }
                }
                
            }
            cell.taskToCancelIfCellReused = task
        }
        cell.imageView.image = cellImage
        
        if selectedIndexes.index(of: indexPath as NSIndexPath) != nil {
            cell.imageView.layer.borderWidth = 2.0
            cell.imageView.layer.borderColor = UIColor.yellow.cgColor
        } else {
            cell.imageView.layer.borderWidth = 0.0
            cell.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
}
extension PhotosViewController : MKMapViewDelegate  {
    
    func configureLocation() {
        if let mapAnnotation = pin {
            let coordinate = CLLocationCoordinate2D(latitude: mapAnnotation.latitude, longitude: mapAnnotation.longitude)
            mapView.addAnnotation(mapAnnotation)
            mapView.camera.altitude = 10000.0
            mapView.setCenter(coordinate, animated: true)
        }
    }
    
    func executeSearch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
        }
    }
}
extension PhotosViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            self.collectionView.insertSections(set)
        case .delete:
            self.collectionView.deleteSections(set)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath! as NSIndexPath)
            break
        case .delete:
            deletedIndexPaths.append(indexPath! as NSIndexPath)
        case .update:
            updatedIndexPaths.append(indexPath! as NSIndexPath)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath as IndexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath as IndexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath as IndexPath])
            }
        },  completion: nil)
    }
}

extension PhotosViewController
{
    func downloadCollection() {
        if pin?.photo?.count == 0 {
            showActivityIndicator()
            FlickerClient.sharedInstance().getPhotosUsingFlickr(pin) { (success, errorString) in
                if success {
                    performUIUpdatesOnMain {
                        self.hideActivityIndicator()
                        AppDelegate.stack.save()
                    }
                }
            }
        }
    }
    func newCollection() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            AppDelegate.stack.context.delete(photo)
        }
        AppDelegate.stack.save()
        if fetchedResultsController.fetchedObjects?.count == 0 {
            showActivityIndicator()
            FlickerClient.sharedInstance().getPhotosUsingFlickr(pin) { (success, errorString) in
                if success {
                    performUIUpdatesOnMain {
                        self.hideActivityIndicator()
                    }
                    AppDelegate.stack.save()
                }
            }
        }
    }
    
    func deleteSelectedPhotos() {
        var deletedPhotos = [Photo]()
        for indexPath in selectedIndexes {
            deletedPhotos.append(fetchedResultsController.object(at: indexPath as IndexPath) as! Photo)
        }
        for photo in deletedPhotos {
            AppDelegate.stack.context.delete(photo)
        }
        AppDelegate.stack.save()
        selectedIndexes = [NSIndexPath]()
        updateButton()
    }
    
    func updateButton() {
        selectedIndexes.count > 0 ? (toolBarButton.title = ButtonTitle.deletePhotos) : (toolBarButton.title = ButtonTitle.newCollection)
    }
}






