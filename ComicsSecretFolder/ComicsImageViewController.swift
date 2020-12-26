//
//  ComicsImageViewController.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 13.12.2020.
//

import UIKit

class ComicsImageViewController: UIViewController {
    
    var model = FetchingData()
    
    @IBOutlet weak var comicsImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showImage()
    }
    
    func showImage(){
        spinner.startAnimating()
        if let url = imageURL{
            model.fetchImage(forCell: 0, url: url){ data in
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self.comicsImageView.image = image
                    }
                }
                else{
                    self.comicsImageView.image = UIImage(named: "noTitleImage")
                }
            }
        }
    }
}
