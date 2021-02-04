//
//  CollectionsViewController.swift
//  UnsplashPhoto
//
//  Created by Сергей on 29.01.2021.
//

import UIKit
import Alamofire

class CollectionsViewController: UIViewController {
    
//MARK: Outlets
    @IBOutlet weak var collectionsCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
//MARK: Variables
        var collectionsArray:[Collection] = []
        var link: String?
        var page = 1
        var totalPages = 1
        var searchTag = "random"
        var totalPhotos:Int?
        var secondFetch = false
        var name:String?

//MARK: Methods
    func fetchPhotos (page:Int = 1, searchTag: String, completion: @escaping (CollectionSearch) -> Void) {
        AF.request(API.collectionsUrl + "?page=\(page)" + "&query=\(searchTag)" + "&" + API.key).responseData {
                response in
                guard let collections = try? JSONDecoder().decode(CollectionSearch.self, from: response.data!) else {
                    let alert = UIAlertController(title: "Error", message: "No response from server", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.collectionsArray.removeAll()
                    self.collectionsCollectionView.reloadData()
                    return
                }
                DispatchQueue.main.async {
                    self.totalPages = collections.totalPages
                    completion(collections)
                }
            }
            }
    
    func firstFetch (page:Int = 1, completion: @escaping ([Collection]) -> Void) {
        AF.request(API.collectionsFirstFetch + "?page=\(page)&" + API.key).responseData {
                response in
            guard let collections = try? JSONDecoder().decode([Collection].self, from: response.data!) else { return }
            self.totalPages += 1
            DispatchQueue.main.async {
                    completion(collections)
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
    
    @objc func hideKeyboardOnSwipeDown() {
            view.endEditing(true)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "collectionDetailsSegue" else { return }
        guard let destination = segue.destination as? CollectionDetailsViewController else { return }
        destination.link = self.link
        destination.totalPhotos = self.totalPhotos
        destination.name = self.name
    }

//MARK: ViewDidLoad
        override func viewDidLoad() {
            super.viewDidLoad()
            searchBar.delegate = self
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.hideKeyboardOnSwipeDown))
                    swipeDown.delegate = self
                    swipeDown.direction =  UISwipeGestureRecognizer.Direction.down
                    self.collectionsCollectionView.addGestureRecognizer(swipeDown)
            firstFetch{ collections in
                self.collectionsArray.append(contentsOf: collections)
                self.collectionsCollectionView.reloadData()
            }
    }
}

//MARK: Collection View extension
extension CollectionsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return collectionsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if page < totalPages && indexPath.row == collectionsArray.count - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCollectionsCell", for: indexPath) as! LoadingCollectionsCell
            cell.spinner.startAnimating()
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionsCell", for: indexPath) as! CollectionsCell
            cell.collectionImage.image = collectionsArray[indexPath.row].coverPhoto.fetchPhoto(collectionsArray[indexPath.row].coverPhoto.urls.thumb)
            cell.collectionLabel.text = collectionsArray[indexPath.row].title
            cell.collectionImage.layer.cornerRadius = 8
            cell.numberOfPhotos.text = String(collectionsArray[indexPath.row].totalPhotos) + " photos"
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
        {
        let width = (collectionsCollectionView.frame.size.width - 30) / 2
           return CGSize(width: width, height: width)
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.link = collectionsArray[indexPath.row].links.photos
        self.totalPhotos = collectionsArray[indexPath.row].totalPhotos
        self.name = collectionsArray[indexPath.row].title
        performSegue(withIdentifier: "collectionDetailsSegue", sender: nil)
            }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if page < totalPages && indexPath.row == collectionsArray.count - 1 {
            page += 1
            if secondFetch == true {
                fetchPhotos(page: page, searchTag: searchTag){collections in
                    self.collectionsArray.append(contentsOf: collections.results)
                    self.collectionsCollectionView.reloadData()
            }
            } else {
                firstFetch(page: page){ collections in
                    self.collectionsArray.append(contentsOf: collections)
                    self.collectionsCollectionView.reloadData()
                }
            }
            
    }
}
}

//MARK: SearchBar extension
extension CollectionsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            self.collectionsArray.removeAll()
            self.page = 1
            self.searchTag =  transliterate(nonLatin: searchBar.text!)
            self.secondFetch = true
            fetchPhotos(searchTag: self.searchTag){ collections in
                self.collectionsArray.append(contentsOf: collections.results)
                self.collectionsCollectionView.reloadData()
            }
        }
    }
    
}

//MARK: GestrureRecognize extension
extension CollectionsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
}
