//
//  Highscore.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 27/12/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import UIKit

struct Highscore: Codable{
    let tijdstip: Date
    let scoreSpeler: Int
    let scoreCPU: Int
    let inzet: Int
    let gebruiker: Gebruiker
}
