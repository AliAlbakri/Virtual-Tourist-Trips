//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Ali Ahmad on 16/07/2020.
//  Copyright © 2020 Ali Ahmed. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
   
    var dataController:DataController!
    var pinLat:Double!
    var pinLon:Double!
   var fetchedResultsController : NSFetchedResultsController<Photo>!
    var pin:Pin!
    
    var insertIndexPaths:[IndexPath]!
    var deleteIndexPaths:[IndexPath]!
    var updateIndexPaths:[IndexPath]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            collectionView.delegate = self
            prepareCollectionViewCells()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
           super.viewDidDisappear(animated)
           fetchedResultsController = nil
       }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
    
        let predicate = NSPredicate(format:"pin == %@" , pin)

        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "downloadDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            print("Working!")
        } catch {
          print(error.localizedDescription)
        }
    }
    fileprivate func prepareCollectionViewCells() {
        if !pin.hasPhotos{
            collectionView.reloadData()
            FlickerAPI.getPhotos(lat:pin.latitude! , lon:pin.longitude!, page: "1" ){ (images, error) in
                guard error == nil else {
                    print(error?.localizedDescription)
                    return
                }
                self.pin.hasPhotos = true
                self.saveImagesToStore(images: images)
            }
        }
        else{
            setupFetchedResultsController()
        }
    }
    
    
    
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        for object in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(object)
        }
        try? dataController.viewContext.save()
        collectionView.reloadData()
        self.pin.hasPhotos = false
        let randomNumber = Int.random(in: 1 ... 99)
        FlickerAPI.getPhotos(lat:pin.latitude! , lon:pin.longitude!, page: "\(randomNumber)" ){ (images, error) in
                     guard error == nil else {
                         print(error?.localizedDescription)
                         return
                     }
                     
                    self.pin.hasPhotos = true
                    self.saveImagesToStore(images: images)
                   
                 }
        
    }
    
    
    func saveImagesToStore(images:[UIImage]){
        for image in images{
            let imageData = image.pngData()
            let photo = Photo(context: dataController.viewContext)
            photo.image = imageData
            photo.downloadDate = Date()
            photo.pin = pin
          try?  dataController.viewContext.save()
          setupFetchedResultsController()
            
        }
        
    }
    

}



extension PhotoAlbumViewController:UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.bounds.width/2 - 3*2), height:(collectionView.bounds.height)/3 - 3*2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}




extension PhotoAlbumViewController:UICollectionViewDataSource,UICollectionViewDelegate{
   
 
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchedResultsController == nil {
            return 10
        }
        else if fetchedResultsController.fetchedObjects!.count == 0 {
            return 10
        }
        else{
            return fetchedResultsController.fetchedObjects!.count
        }
        
    }
    
        
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionVCCell
        cell.imageView.image = UIImage(named: "Virtual")
        
        if fetchedResultsController == nil {
            return cell
        }
            
        else if fetchedResultsController.fetchedObjects!.count < 1 {
            return cell
        }
        else {
                        let photo = fetchedResultsController.object(at: indexPath)
                        let image = UIImage(data: photo.image!)
                        cell.imageView.image = image
                        return cell
        }
        
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if fetchedResultsController.fetchedObjects!.count > 0 {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
        }
    }
    
    
    
}






extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertIndexPaths = [IndexPath]()
        deleteIndexPaths = [IndexPath]()
       updateIndexPaths  = [IndexPath]()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type{

        case .insert:
            self.insertIndexPaths.append(newIndexPath!)
 
        case .delete:
            self.deleteIndexPaths.append(indexPath!)
        
           
        case .update:
            updateIndexPaths.append(indexPath!)
        default:
            break

       
    }
    }
    
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        collectionView.performBatchUpdates({
            for indexPath in self.insertIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }

            for indexPath in self.deleteIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }

            for indexPath in self.updateIndexPaths{
                self.collectionView.reloadItems(at: [indexPath])
            }

        }, completion: {finished in
        })
    }
 }

    
    
    

