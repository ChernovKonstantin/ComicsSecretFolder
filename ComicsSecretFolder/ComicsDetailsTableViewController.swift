//
//  ComicsSearchTableViewController.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 12.12.2020.
//

import UIKit

class ComicsDetailsTableViewController: UITableViewController {
    
    var model = FetchingData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.urlRequest(url: model.urlForRequest, for: model.currentURLRequestIndex)
    }
    
    // MARK: - URL Request
    
    func urlRequest(url: URL, for currentURLRequest: Int){
        let session = URLSession(configuration: .default)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.model.currectURLSession = session.dataTask(with: url) { data, response, error in
                guard currentURLRequest == self?.model.currentURLRequestIndex else { return }
                guard error == nil else{ print("Error occured during url request: \(error!)"); return }
                if let data = data{
                    self?.model.processDataForComicsRequest(data)
                } else{
                    print("No Data received from the Server")
                    if let response = response{ print(response) }
                }
                DispatchQueue.main.async {
                    if let list = self?.model.comicsList{
                        if !list.isEmpty{
                            self?.tableView.reloadData()
                            self?.downloadImage(for: (self?.model.currentURLRequestIndex)!)
                        }else{
                            self?.showInformation()}
                    }
                    self?.model.additionalRequestInProcess = false
                    
                }
            }
            self?.model.currectURLSession!.resume()
        }
    }
    
    func downloadImage(for currentURLRequest: Int) {
        loop: for index in model.requestOffset...model.comicsList.count-1{
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let url = self?.model.comicsList[index].thumbnail?.url{
                    let download = URLSession(configuration: .default)
                    download.dataTask(with: url, completionHandler: {data, response, error in
                        guard currentURLRequest == self?.model.currentURLRequestIndex else { return }
                        guard error == nil else{ print("Error occured during url request: \(error!)"); return }
                        if let data = data{
                            if let list = self?.model.comicsList{
                                guard list.indices.contains(index) else { return }
                                self?.model.comicsList[index].icon = data
                            }
                        }
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }).resume()
                }
            }
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.comicsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if model.additionalDataIsAvailable && indexPath.row == model.comicsList.count-1, !model.additionalRequestInProcess {
            self.model.updateOffsetForRequest()
            self.urlRequest(url: model.urlForRequest, for: model.currentURLRequestIndex)
            self.model.additionalRequestInProcess = true
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComicsCell", for: indexPath)
        let listItem = model.comicsList[indexPath.row]
        cell.textLabel?.text = listItem.title
        if let price = listItem.prices?.first?.price{
            if price == 0.0{
                cell.detailTextLabel!.text = "Not available"
            }else{
                cell.detailTextLabel!.text = "$\(price)"
            }
        }
        if let image = listItem.icon {
            cell.imageView?.image = UIImage(data: image)
        }else{
            cell.imageView?.image = UIImage(named: "noImage")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comics = model.comicsList[indexPath.row]
        performSegue(withIdentifier: "ComicsImage", sender: comics)
    }
    
    
    //    MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ComicsImage"{
            let controller = segue.destination as! ComicsImageViewController
            if let imageURL = (sender as! Comics).thumbnail{
                controller.imageURL = imageURL.urlForBigTitle
            }
        }
    }
    
    //MARK: - Notification
    
    func showInformation(){
        let message = "No comics available on your request.\n"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


