//
//  TableViewController.swift
//  ShoppingList
//
//  Created by Eric Alves Brito.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit

final class ListTableViewController: UITableViewController {

    // MARK: Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - IBActions
    @IBAction func addItem(_ sender: Any) {
    }

}
