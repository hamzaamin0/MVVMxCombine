//
//  NetworkService.swift
//  MVVm-Combine
//
//  Created by MAC on 09/10/2021.
//

import Foundation

class NetworkService{
    
    static let shared = NetworkService()
    
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> ()){
        
        let strUrl = "https://jsonplaceholder.typicode.com/users"
        let url = URL(string: strUrl)!
        
        URLSession.shared.dataTask(with: url){ (data, response, error) in
            
            if let error = error{
                
                completion(.failure(error))
                return
            }
            guard let data = data else {return}
            do {
                
                let users = try JSONDecoder().decode([User].self, from: data)
                completion(.success(users))
                
            }catch (let error){
                
                print(error.localizedDescription)
            }
            
        }.resume()
        
    }
    
}
