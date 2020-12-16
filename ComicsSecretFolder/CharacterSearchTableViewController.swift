//
//  CharacterSearchTableViewController.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 12.12.2020.
//

import UIKit

class CharacterSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var model = FetchingData()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.searchingOption = .forCharacters
    }
    
    // MARK: - URL Request
    
    func urlRequest(url: URL, for currentURLRequest: Int){
        let session = URLSession(configuration: .default)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.model.currectURLSession = session.dataTask(with: url) { data, response, error in
                guard currentURLRequest == self?.model.currentURLRequestIndex else { return }
                guard error == nil else{ print("Error occured during url request: \(error!)"); return }
                if let data = data{
                    self?.model.processDataForCharacterRequest(data)
                } else{
                    print("No Data received from the Server")
                    if let response = response{ print(response) }
                }
                DispatchQueue.main.async {
                    if let list = self?.model.charactersList{
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
        for index in model.requestOffset...model.charactersList.count-1{
            DispatchQueue.global(qos: .userInitiated).async {[weak self] in
                if let url = self?.model.charactersList[index].thumbnail?.url{
                    let download = URLSession(configuration: .default)
                    download.dataTask(with: url, completionHandler: {data, response, error in
                        guard currentURLRequest == self?.model.currentURLRequestIndex else { return }
                        guard error == nil else{ print("Error occured during url request: \(error!)"); return }
                        if let data = data{
                            if let list = self?.model.charactersList{
                                guard list.indices.contains(index) else { return }
                                self?.model.charactersList[index].icon = data
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
        return model.charactersList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if model.additionalDataIsAvailable, indexPath.row == model.charactersList.count-1, !model.additionalRequestInProcess {
            self.model.updateOffsetForRequest()
            self.urlRequest(url: model.urlForRequest, for: model.currentURLRequestIndex)
            self.model.additionalRequestInProcess = true
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath)
        let listItem = model.charactersList[indexPath.row]
        cell.textLabel?.text = listItem.name
        if let image = listItem.icon {
            cell.imageView?.image = UIImage(data: image)
        }else{
            cell.imageView?.image = UIImage(named: "noImage")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let character = model.charactersList[indexPath.row]
        model.searchingParameterValueForComics = String(character.id!)
        performSegue(withIdentifier: "ByCharacter", sender: character)
    }
    
    //     MARK: - Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text{
            model.newSearch()
            if !model.charactersList.isEmpty{
                model.charactersList.removeAll()
                tableView.reloadData()
            }
            searchBar.resignFirstResponder()
            model.searchingParameterValue = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20")
            if model.currectURLSession != nil { model.currectURLSession!.cancel() }
            self.urlRequest(url: model.urlForRequest, for: model.currentURLRequestIndex)
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
