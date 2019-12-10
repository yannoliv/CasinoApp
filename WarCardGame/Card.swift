//
//  Card.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 10/12/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import Foundation

struct Card:Codable{
    var image = URL(string:"")
    var value: String = ""
    var suit: String = ""
    var code: String = ""
    
    enum CodingKeys: String, CodingKey{
        case image, value, suit, code
    }
    
    init(from decoder: Decoder) throws{
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.image = try valueContainer.decode(URL.self, forKey: CodingKeys.image)
        self.value = try valueContainer.decode(String.self, forKey: CodingKeys.value)
        self.suit = try valueContainer.decode(String.self, forKey: CodingKeys.suit)
        self.code = try valueContainer.decode(String.self, forKey: CodingKeys.code)
    }
}
