//
//  DrawCard.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 10/12/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import Foundation

struct DrawCard: Codable{
    var success:Bool = false
    var cards: [Card] = []
    var deckID: String = ""
    var remaining: Int = 0
    
    enum CodingKeys: String, CodingKey{
        case success, cards, deckID="deck_id", remaining
    }
    
    init(from decoder: Decoder) throws{
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try valueContainer.decode(Bool.self, forKey: CodingKeys.success)
        self.cards = try valueContainer.decode([Card].self, forKey: CodingKeys.cards)
        self.deckID = try valueContainer.decode(String.self, forKey: CodingKeys.deckID)
        self.remaining = try valueContainer.decode(Int.self, forKey: CodingKeys.remaining)
    }
}
