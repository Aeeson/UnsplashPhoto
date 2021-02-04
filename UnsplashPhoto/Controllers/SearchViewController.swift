//
//  SearchViewController.swift
//  UnsplashPhoto
//
//  Created by Сергей on 29.01.2021.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    //MARK: Variables
        var photosArray:[Photo] = []
        var selectedPhoto:Photo?
        var page = 1
        var totalPages = 1
        var searchTag = "random"

    //MARK: Methods
    func fetchPhotos (page:Int = 1, searchTag: String, completion: @escaping (SearchResult) -> Void) {
        AF.request(API.searchUrl + "?page=\(page)" + "&query=\(searchTag)" + "&" + API.key).responseData { response in
            guard let photos = try? JSONDecoder().decode(SearchResult.self, from: response.data!) else {
                self.photosArray.removeAll()
                self.searchCollectionView.reloadData()
                return
            }
                DispatchQueue.main.async {
                    completion(photos)
                }
            }
            }
    
    func transliterate(nonLatin: String) -> String {
        return nonLatin
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false)?
            .replacingOccurrences(of: " ", with: "+")
            .lowercased() ?? nonLatin
    }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            searchBar.delegate = self
            fetchPhotos(page: 1, searchTag: searchTag) { photos in
                self.photosArray.append(contentsOf: photos.results)
                self.totalPages = photos.totalPages
                self.searchCollectionView.reloadData()
            }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "searchSegue" else { return }
        guard let destination = segue.destination as? DetailsViewController else { return }
        destination.photo = self.selectedPhoto
    }
}

//MARK: Collection View extension

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if page < totalPages && indexPath.row == photosArray.count - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCell
            cell.searchCellImageView.image = photosArray[indexPath.row].fetchPhoto(photosArray[indexPath.row].urls.thumb)
            cell.searchCellImageView.layer.cornerRadius = 8
            cell.likesLabel.text = "🤍 " + String(photosArray[indexPath.row].likes)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
        {
        let width = (searchCollectionView.frame.size.width - 30) / 2
           return CGSize(width: width, height: width)
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedPhoto = photosArray[indexPath.row]
        performSegue(withIdentifier: "searchSegue", sender: nil)
            }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if page < totalPages && indexPath.row == photosArray.count - 1 {
            page += 1
            fetchPhotos(page: page, searchTag: searchTag){photos in
                self.photosArray.append(contentsOf: photos.results)
                self.searchCollectionView.reloadData()
            }
    }
}
    
}

//MARK: SearchBar extension

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            self.photosArray.removeAll()
            self.page = 1
            self.searchTag =  transliterate(nonLatin: searchBar.text!)
            fetchPhotos(searchTag: self.searchTag){ photos in
                self.photosArray.append(contentsOf: photos.results)
                self.searchCollectionView.reloadData()
            }
        }
    }
    
}
