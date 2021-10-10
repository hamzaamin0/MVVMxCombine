//
//  ViewController.swift
//  MVVm-Combine
//
//  Created by MAC on 09/10/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usersTableView: UITableView!
    
    var users: [User] = []{
        
        didSet{
            print(users, "users...")
            usersTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        fetchUsers()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func fetchUsers(){
        
        NetworkService.shared.fetchUsers { (result) in
            switch result{
            
            case .failure(let error):
                print(error.localizedDescription)
                
                
            case .success(let users):
                DispatchQueue.main.async {
                    self.users = users
                }
                
            }
        }
        
    }


}


extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let user = users[indexPath.row]
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.email
        return cell!
    }
    
}

struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}
