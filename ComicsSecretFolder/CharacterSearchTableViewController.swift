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
    
    func fetchDataList(){
        model.downloadData(){ (result: Result<[Character], Error>) in
            switch result{
            case .failure(let error): print(error)
            case .success(let array): self.listForTableView.append(contentsOf: array)
                DispatchQueue.main.async {
                    if !self.listForTableView.isEmpty{
                        self.tableView.reloadData()
                    }else{
                        self.showInformation()
                    }
                }
            }
        }
    }
    
    func fetchImages(forCell index: Int){
        guard listForTableView[index].icon == nil else { return }
        if let url = listForTableView[index].thumbnail?.url{
            model.fetchImage(forCell: index, url: url){image in
                guard self.listForTableView.indices.contains(index) else { return }
                self.listForTableView[index].icon = image
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listForTableView.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if model.additionalDataIsAvailable, indexPath.row == listForTableView.count-1{
            self.fetchDataList()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath)
        let listItem = listForTableView[indexPath.row]
        cell.textLabel?.text = listItem.name
        if let image = listItem.icon {
            cell.imageView?.image = UIImage(data: image)
        }else{
            cell.imageView?.image = UIImage(named: "noImage")
            fetchImages(forCell: indexPath.row)
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
            model.searchingParameterValue = text.filter({model.acceptableChars.contains($0.lowercased())}).trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20")
            self.fetchDataList()
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
