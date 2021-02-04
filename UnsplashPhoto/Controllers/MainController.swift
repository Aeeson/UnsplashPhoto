//
//  MainController.swift
//  UnsplashPhoto
//
//  Created by Сергей on 27.01.2021.
//

import UIKit
import Alamofire

class MainController: UIViewController {
    
//MARK: Outlets
    @IBOutlet weak var randomPhotoImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    
//MARK: Variables
    var randomPhoto:Photo?
    
//MARK: Methods
    func fetchRandomPhoto (completion: @escaping (Photo) -> Void) {
        AF.request(API.url + "random" + "?" + API.key).responseData {
            response in
            guard let randomPhotoData = try? JSONDecoder().decode(Photo.self, from: response.data!) else { return }
            self.randomPhotoImageView.image = randomPhotoData.fetchPhoto(randomPhotoData.urls.small)
            DispatchQueue.main.async {
                completion(randomPhotoData)
            }
        }
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard segue.identifier == "randomPhotoDetailsSegue" else { return }
            guard let destination = segue.destination as? DetailsViewController else { return }
            destination.photo = randomPhoto
        }

//MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRandomPhoto{ randomPhoto in
            self.randomPhoto = randomPhoto
            self.likesLabel.text = "❤️ " + String(randomPhoto.likes)
        }
    }
}
