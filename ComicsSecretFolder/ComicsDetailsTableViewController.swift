//
//  ComicsSearchTableViewController.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 12.12.2020.
//

import UIKit

class ComicsDetailsTableViewController: UITableViewController {
    
    var model = FetchingData()
    var listForTableView = [Comics]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchDataList(forRequest: model.currentURLRequestIndex)
    }
    
    // MARK: - URL Request
    
    func fetchDataList(forRequest currentURLRequest: Int){
        model.downloadData(forRequest: currentURLRequest) { (result: Result<ComicsMarvelData, DataError>) in
            switch result{
            case .failure(let error): print(error)
            case .success(let container):
                if let array = container.data?.results { self.listForTableView.append(contentsOf: array)}
                if let numberOfRecords = container.data?.total{ self.model.totalRecordsCount = numberOfRecords}
                DispatchQueue.main.async {
                    if !self.listForTableView.isEmpty{
                        self.tableView.reloadData()
                        self.fetchImages(forRequest: currentURLRequest)
                    }else{
                        self.showInformation()
                    }
                    self.model.additionalRequestInProcess = false
                }
            }
        }
    }
    
    func fetchImages(forRequest currentURLRequest: Int){
        for index in model.requestOffset...listForTableView.count-1{
            if let url = self.listForTableView[index].thumbnail?.url{
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    if let image = try? Data(contentsOf: url){
                        guard currentURLRequest == self?.model.currentURLRequestIndex else { return }
                        self?.listForTableView[index].icon = image
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listForTableView.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if model.additionalDataIsAvailable && indexPath.row == listForTableView.count-1, !model.additionalRequestInProcess {
            self.model.updateOffsetForRequest()
            self.fetchDataList(forRequest: model.currentURLRequestIndex)
            self.model.additionalRequestInProcess = true
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComicsCell", for: indexPath)
        let listItem = listForTableView[indexPath.row]
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
        let comics = listForTableView[indexPath.row]
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
