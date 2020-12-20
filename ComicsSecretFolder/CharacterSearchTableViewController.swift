//
//  CharacterSearchTableViewController.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 12.12.2020.
//

import UIKit

class CharacterSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var model = FetchingData(searching: .forCharacters)
    var listForTableView = [Character]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - URL Request
    
    func fetchDataList(forRequest currentURLRequest: Int){
        model.downloadData(forRequest: currentURLRequest) { (result: Result<CharacterMarvelData, DataError>) in
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
        if model.additionalDataIsAvailable, indexPath.row == listForTableView.count-1, !model.additionalRequestInProcess {
            self.model.updateOffsetForRequest()
            self.fetchDataList(forRequest: model.currentURLRequestIndex)
            self.model.additionalRequestInProcess = true
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath)
        let listItem = listForTableView[indexPath.row]
        cell.textLabel?.text = listItem.name
        if let image = listItem.icon {
            cell.imageView?.image = UIImage(data: image)
        }else{
            cell.imageView?.image = UIImage(named: "noImage")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let character = listForTableView[indexPath.row]
        model.searchingParameterValueForComics = String(character.id!)
        performSegue(withIdentifier: "ByCharacter", sender: character)
    }
    
    //     MARK: - Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text{
            model.newSearch()
            if !listForTableView.isEmpty{
                listForTableView.removeAll()
                tableView.reloadData()
            }
            searchBar.resignFirstResponder()
            model.searchingParameterValue = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20")
            self.fetchDataList(forRequest: model.currentURLRequestIndex)
        }
    }
    
    //    MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ByCharacter"{
            let controller = segue.destination as! ComicsDetailsTableViewController
            controller.model.searchingParameterValue = model.searchingParameterValueForComics
            controller.model.searchingOption = .comicsByCharacterID
        }
    }
    
    //MARK: - Notification
    
    func showInformation(){
        let message = "No characters available on your request."
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
