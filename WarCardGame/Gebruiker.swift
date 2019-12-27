//
//  Gebruiker.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 10/12/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import Foundation

struct Gebruiker: Codable{
    let naam: String
    var currency: Int
    
    init(){
        naam = "anoniem"
        currency = 400
    }
}
