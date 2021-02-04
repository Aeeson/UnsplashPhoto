//
//  CollectionDetailsViewController.swift
//  UnsplashPhoto
//
//  Created by Сергей on 29.01.2021.
//

import UIKit
import Alamofire

class CollectionDetailsViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var collectionPhotosView: UICollectionView!
    @IBOutlet weak var collectionName: UILabel!
    
    
    
    //MARK: Variables
        var photosArray:[Photo] = []
        var selectedPhoto:Photo?
        var link:String?
        var totalPhotos:Int?
        var page = 1
        var totalPages = 1
        var name:String?

    //MARK: Methods
    func fetchPhotos (page: Int, completion: @escaping ([Photo]) -> Void) {
        AF.request(self.link! + "?page=\(page)" + "&" + API.key).responseData {
                response in
            guard let photos = try? JSONDecoder().decode([Photo].self, from: response.data!) else { return }
                DispatchQueue.main.async {
                    completion(photos)
                }
            }
            }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            collectionName.text = name
            totalPages = totalPhotos! / 10
            let remainder = totalPhotos! % 10
            if remainder > 0 { totalPages += 1 }
            fetchPhotos (page: page){ photos in
                self.photosArray.append(contentsOf: photos)
                self.collectionPhotosView.reloadData()
            }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "collectionPhotoDetailsSegue" else { return }
        guard let destination = segue.destination as? DetailsViewController else { return }
        destination.photo = self.selectedPhoto
    }
}

//MARK: Collection View extension

extension CollectionDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if page < totalPages && indexPath.row == photosArray.count - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCollectionPhotosCell", for: indexPath) as! LoadingCollectionPhotosCell
            cell.spinner.startAnimating()
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionDetailsCell", for: indexPath) as! CollectionDetailsCell
            cell.collectionPhotosImage.image = photosArray[indexPath.row].fetchPhoto(photosArray[indexPath.row].urls.thumb)
            cell.collectionPhotosImage.layer.cornerRadius = 8
            cell.likesLabel.text = "🤍 " + String(photosArray[indexPath.row].likes)
            return cell
        }
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
        {
        let width = (collectionPhotosView.frame.size.width - 30) / 2
           return CGSize(width: width, height: width)
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedPhoto = photosArray[indexPath.row]
        performSegue(withIdentifier: "collectionPhotoDetailsSegue", sender: nil)
            }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if page < totalPages && indexPath.row == photosArray.count - 1 {
            page += 1
            fetchPhotos(page: page){photos in
                self.photosArray.append(contentsOf: photos)
                self.collectionPhotosView.reloadData()
            }
    }
}
}
