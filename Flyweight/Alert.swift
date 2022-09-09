//
//  Alert.swift
//  Flyweight
//
//  Created by Macbook on 15.05.2022.
//


import UIKit

extension UIViewController {
    
    func alerAddAdress(title: String, placeholder: String, complition: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Ok", style: .default) { action in
            let textField = alert.textFields?.first
            guard let text = textField?.text else {return}
            complition(text)
        }
        alert.addTextField { textField in
            textField.placeholder = placeholder
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(alertOk)
        alert.addAction(alertCancel)
        present(alert, animated: true, completion: nil)
    }
     
    func alertError(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(actionOk)
        present(alert, animated: true, completion: nil)
    }
    
}
