//
//  ViewController.swift
//  ShoppingList
//
//  Created by Matheus Lopes.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit
import Firebase

final class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var labelCopyright: UILabel!
    
    // MARK: - Properties
    private lazy var auth = Auth.auth()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func signIn(_ sender: Any) {
        auth.signIn(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { result, error in
            if let error = error {
                let authErrorCode = AuthErrorCode.Code(rawValue: error._code)
                switch authErrorCode {
                case .invalidEmail:
                    print("E-mail inválido")
                case .wrongPassword:
                    print("Senha incorreta")
                default:
                    print("Erro desconhecido : \(error.localizedDescription)")
                }
            } else {
                guard let user = result?.user else { return }
                self.updateUserAndProceed(user: user)
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        auth.createUser(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { result, error in
            if let error = error {
                let authErrorCode = AuthErrorCode.Code(rawValue: error._code)
                switch authErrorCode {
                case .invalidEmail:
                    print("E-mail inválido")
                case .emailAlreadyInUse:
                    print("Conta já existente")
                case .weakPassword:
                    print("Senha muito fraca")
                default:
                    print("Erro desconhecido : \(error.localizedDescription)")
                }
            } else {
                guard let user = result?.user else { return }
                self.updateUserAndProceed(user: user)
            }
        }
    }
    
    // MARK: - Methods
    private func updateUserAndProceed(user: User) {
        if let name = textFieldName.text, !name.isEmpty {
            let request = user.createProfileChangeRequest()
            request.displayName = name
            request.commitChanges { error in
                if let error = error { print(error) }
                self.goToMainScreen()
            }
        } else { goToMainScreen() }
    }
    
    private func goToMainScreen() {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ListTableViewController") {
            show(viewController, sender: nil)
        }
    }
}

