//
//  CreatorSearchTableViewController.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 12.12.2020.
//

import UIKit

class CreatorSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var model = FetchingData(searching: .forCreators)
    var listForTableView = [Creator]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - URL Request
    
    func fetchDataList(forRequest currentURLRequest: Int){
        model.downloadData(forRequest: currentURLRequest){ (result: Result<[Creator], Error>) in
            switch result{
            case .failure(let error): print(error)
            case .success(let array): self.listForTableView.append(contentsOf: array)
                DispatchQueue.main.async {
                    if !self.listForTableView.isEmpty{
                        self.tableView.reloadData()
                        self.fetchImages(forRequest: currentURLRequest)
                    }else{
                        self.showInformation()
                    }
                }
            }
        }
    }
    
    func fetchImages(forRequest currentURLRequest: Int){
        for index in listForTableView.indices{
            guard listForTableView[index].icon == nil else { continue }
            if let url = listForTableView[index].thumbnail?.url{
                model.fetchImage(forCell: index, forRequest: currentURLRequest, url: url){image in
                    self.listForTableView[index].icon = image
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
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
        if model.additionalDataIsAvailable, indexPath.row == listForTableView.count-1, !model.additionalRequestInProcess {
            self.model.updateOffsetForRequest()
            self.fetchDataList(forRequest: model.currentURLRequestIndex)
            self.model.additionalRequestInProcess = true
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatorCell", for: indexPath)
        let listItem = listForTableView[indexPath.row]
        cell.textLabel?.text = listItem.fullName
        if let image = listItem.icon {
            cell.imageView?.image = UIImage(data: image)
        }else{
            cell.imageView?.image = UIImage(named: "noImage")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let creator = listForTableView[indexPath.row]
        model.searchingParameterValueForComics = String(creator.id!)
        performSegue(withIdentifier: "ByCreator", sender: creator)
    }
    
    // MARK: - Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text{
            self.model.newSearch()
            if !listForTableView.isEmpty{
                listForTableView.removeAll()
                self.tableView.reloadData()
            }
            searchBar.resignFirstResponder()
            model.searchingParameterValue = text.filter({model.acceptableChars.contains($0.lowercased())}).trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20")
            self.fetchDataList(forRequest: model.currentURLRequestIndex)
        }
    }
    
    //    MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ByCreator"{
            let controller = segue.destination as! ComicsDetailsTableViewController
            controller.model.searchingParameterValue = model.searchingParameterValueForComics
            controller.model.searchingOption = .comicsByCreator
        }
    }
    
    //MARK: - Notification
    
    func showInformation(){
        let message = "No creators available on your request."
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
