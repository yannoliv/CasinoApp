//
//  Deck.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 12/11/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import Foundation

class Deck: Codable{
    var success:Bool
    var deckID: String
    var shuffled: Bool
    var remaining: Int
    
    enum CodingKeys: String, CodingKey{
        case success, deckID="deck_id", shuffled, remaining
    }
    
    init(from decoder: Decoder) throws{
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try valueContainer.decode(Bool.self, forKey: CodingKeys.success)
        self.deckID = try valueContainer.decode(String.self, forKey: CodingKeys.deckID)
        self.shuffled = try valueContainer.decode(Bool.self, forKey: CodingKeys.shuffled)
        self.remaining = try valueContainer.decode(Int.self, forKey: CodingKeys.remaining)
    }
}
