//
//  RemoteConfigValues.swift
//  ShoppingList
//
//  Created by Matheus Lopes on 22/09/22.
//  Copyright © 2022 FIAP. All rights reserved.
//

import Foundation
import Firebase

class RemoteConfigValues {
    
    static let shared = RemoteConfigValues()
    private let remoteConfig = RemoteConfig.remoteConfig()
    private let copyrightMessageDefaultValue = "Copyright 2022 - FIAP"
    
    var copyrightMessage: String {
        remoteConfig.configValue(forKey: "copyrightMessage").stringValue ?? copyrightMessageDefaultValue
    }
    
    private init() {
        loadDefaultValues()
    }
    
    private func loadDefaultValues() {
        let defaultValues: [String:Any] = [
            "copyrightMessage":copyrightMessageDefaultValue
        ]
        remoteConfig.setDefaults(defaultValues as? [String:NSObject])
    }
    
    func fetch() {
        print("Chamada ao método RemoteConfigValues.fetch()")
        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("Error Fetch: ", error.localizedDescription)
            } else {
                switch status {
                case .error:
                    print("Error no fetch")
                case .successFetchedFromRemote:
                    print("Atualizou a partir da nuvem")
                case .successUsingPreFetchedData:
                    print("Atualizou com os dados em cache")
                default:
                    print("Status desconhecido")
                }
            }
        }
    }
}
