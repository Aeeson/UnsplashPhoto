//
//  DetailsViewController.swift
//  UnsplashPhoto
//
//  Created by Сергей on 27.01.2021.
//

import UIKit

class DetailsViewController: UIViewController {
//MARK: Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBAction func infoButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Info", message: "Size: \(self.photo!.height) x \(self.photo!.width)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func urlsButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "URL", message: self.photo?.urls.full ?? "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Copy", style: UIAlertAction.Style.default) { action in
            UIPasteboard.general.string = self.photo?.urls.full ?? ""
        })
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
//MARK: Variables
    var photo:Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let photo = photo {
            photoImageView.image = photo.fetchPhoto(photo.urls.small)
            descriptionLabel.text = photo.altDescription ?? "No description"
            likesLabel.text = "❤️ " + String(photo.likes)
            authorNameLabel.text = photo.user.username
            avatarImageView.image = photo.fetchPhoto(photo.user.profileImage.small)
            avatarImageView.layer.cornerRadius = 25
            avatarImageView.clipsToBounds = true
        }

    }
    
}
