//
//  ComicsImageViewController.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 13.12.2020.
//

import UIKit

class ComicsImageViewController: UIViewController {
    
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
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let image = try? Data(contentsOf: url){
                    DispatchQueue.main.async {
                        self?.comicsImageView.image = UIImage(data: image)
                    }
                } else{
                    self?.comicsImageView.image = UIImage(named: "noTitleImage")
                }
            }
        }
    }
}
