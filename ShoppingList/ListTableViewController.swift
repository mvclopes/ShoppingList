//
//  TableViewController.swift
//  ShoppingList
//
//  Created by Matheus Lopes.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit
import Firebase

final class ListTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let collection = "shoppingList"
    private var shoppingList: [ShoppingItem] = []
    private lazy var fireStore: Firestore = {
        // Configurando o banco de dados
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        let firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    private var listener: ListenerRegistration!

    // MARK: Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser, let name = user.displayName {
            title = "Compras do \(name)"
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Sair",
            style: .plain,
            target: self,
            action: #selector(signOut)
        )
        loadShoppingList()
    }
    
    private func loadShoppingList() {
        listener = fireStore
            .collection(collection)
            .order(by: "name")
            .limit(to: 20)
            .addSnapshotListener(includeMetadataChanges: true, listener: { snapshot, error in
                if let error = error {
                    print("Error: ", error.localizedDescription)
                } else {
                    guard let snapshot = snapshot else { return }
                    // Validação se os dados são locais ou se houve alteração no banco de dados remoto (FireStore)
                    if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                        self.showItemsFrom(snapshot: snapshot)
                    }

                }
            })
    }
    
    private func showItemsFrom(snapshot: QuerySnapshot) {
        shoppingList.removeAll()
        for document in snapshot.documents {
            let data = document.data()
            if let name = data["name"] as? String,
               let quantity = data["quantity"] as? Int {
                let shoppingItem = ShoppingItem(
                    name: name,
                    quantity: quantity,
                    id: document.documentID
                )
                shoppingList.append(shoppingItem)
            }
        }
        tableView.reloadData()
    }
    
    @objc private func signOut() {
        do {
            try Auth.auth().signOut()
            guard let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") else { return }
            navigationController?.viewControllers = [loginViewController]
        } catch {
            print("Error: ", error.localizedDescription)
        }
        
    }
    
    private func showAlertFor(_ shoppingItem: ShoppingItem? = nil) {
        let alert = UIAlertController(
            title: "Produto",
            message: "Entre com as informações do produto",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Nome"
            textField.text = shoppingItem?.name
        }
        alert.addTextField { textField in
            textField.placeholder = "Quantidade"
            textField.keyboardType = .numberPad
            textField.text = shoppingItem?.quantity.description
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let name = alert.textFields?.first?.text,
                  let quantityString = alert.textFields?.last?.text,
                  let quantity = Int(quantityString) else { return }
            
            let data: [String:Any] = [
                "name": name,
                "quantity": quantity
            ]
            
            if let shoppingItem = shoppingItem {
                self.fireStore
                    .collection(self.collection)
                    .document(shoppingItem.id)
                    .updateData(data)
            } else {
                self.fireStore
                    .collection(self.collection)
                    .addDocument(data: data)
            }
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .destructive)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let shoppingItem = shoppingList[indexPath.row]
        
        cell.textLabel?.text = shoppingItem.name
        cell.detailTextLabel?.text = "\(shoppingItem.quantity)"
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shoppingItem = shoppingList[indexPath.row]
        showAlertFor(shoppingItem)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let shopping = shoppingList[indexPath.row]
            fireStore
                .collection(collection)
                .document(shopping.id)
                .delete()
        }
    }
    
    // MARK: - IBActions
    @IBAction func addItem(_ sender: Any) {
        showAlertFor()
    }

}
