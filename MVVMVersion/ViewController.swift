//
//  ViewController.swift
//  MVVMVersion
//
//  Created by MAC on 09/10/2021.
//

import UIKit
import Combine

class UsersViewModel {
    
    //Dependency Injection
    private let apiManager: ApiManager
    private let endpoint: Endpoint
    
    var userSubject = PassthroughSubject<[User], Error>()
    
    init(apiManager: ApiManager, endpoint: Endpoint ) {
        self.apiManager = apiManager
        self.endpoint = endpoint
    }
    
    func fetchUsers() {
        
        let url = URL(string: endpoint.urlString)!
        apiManager.fetchItems(url: url) { [weak self] (result: Result<[User], Error>) in
            switch result{
            
            case .success(let usersArray):
                self?.userSubject.send(usersArray)
            case .failure(let error):
                self?.userSubject.send(completion: .failure(error))
                
                
            }
        }
        
    }
}

class UsersTableViewController: UITableViewController {

    var viewModel: UsersViewModel?
    private let apiManager = ApiManager()
    var users: [User] = []
    var subscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        fetchUsers()
        observeViewModel()
        // Do any additional setup after loading the view.
    }


    private func setupViewModel(){
    
        viewModel = UsersViewModel(apiManager: apiManager, endpoint: .fetchUser)
        
    }
    private func fetchUsers(){
        
        viewModel?.fetchUsers()
        
    }
    
    private func observeViewModel(){
        
        subscriber = viewModel?.userSubject.sink(receiveCompletion: { (resultCompletion) in
            switch resultCompletion{
            
            case .failure(let error):
                
                print(error.localizedDescription)
            case .finished: break
            
            }
            
        }) { (usersArr) in
            
            DispatchQueue.main.async {
                self.users = usersArr
                self.tableView.reloadData()
            }
            
        }

        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
}


class ApiManager{
    
    private var subscribers = Set<AnyCancellable>()
    
    func fetchItems<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void){
//        let strUrl = "https://jsonplaceholder.typicode.com/users"
//        let url = URL(string: strUrl)
        URLSession.shared.dataTaskPublisher(for: url)
            .map{ $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .sink { (resultCompletion) in
                switch resultCompletion{
                case .failure(let error):
                    completion(.failure(error))
                case .finished: break
                    
                }
            } receiveValue: { (resultsArray) in
                completion(.success(resultsArray))
            }.store(in: &subscribers)

    }
    
}



struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}

enum Endpoint {
    case fetchUser
    var urlString: String{
        switch self {
        
        case .fetchUser:
            return "https://jsonplaceholder.typicode.com/users"
        
        }
    }
}
