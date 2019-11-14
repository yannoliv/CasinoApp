//
//  MenuViewController.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 22/10/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import UIKit

class BlackjackViewController: UIViewController {
    
    @IBOutlet private var topCustomButton: NieuweButton!
    var bottomCustomButton = NieuweButton()
    
    @IBOutlet weak var leftImageView: UIImageView!
    
    var deckID: String=""
    
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchDeck{
            (deck) in
            guard let deck = deck else {return}
            print(deck)
            self.deckID = deck.deckID
        }
        
    }
    
    @IBAction func dealTapped(_ sender: NieuweButton) {
        topCustomButton.shake()
        
        self.trekKaart{
            (drawCard) in
            guard let drawCard = drawCard else {return}
            print(drawCard)
            
            DispatchQueue.main.async {
                self.leftImageView.image = UIImage(named:"kaarten/\(drawCard.cards[0].code)")
            }
        }
        
    }
    
    
    // Deck ophalen. Hiervan hebben we de ID nodig: deckID
    func fetchDeck(completion: @escaping(Deck?) -> Void){
        let deckURL = URL(string: "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1")!
        
        let task = URLSession.shared.dataTask(with: deckURL){(data, response, error) in
            
            let jsondecoder = JSONDecoder()
            
            if let data = data,
                let deck = try? jsondecoder.decode(Deck.self, from:data){
                completion(deck)
            } else {
                print("Either no data was returned, or data was not properly decoded.")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    // 1 kaart trekken. https: //deckofcardsapi.com/api/deck/<<deck_id>>/draw/?count=2
    func trekKaart(completion: @escaping(DrawCard?) -> Void){
            
        let trekKaartURL = URL(string : "https://deckofcardsapi.com/api/deck/\(self.deckID)/draw/?count=1")
        
        let task = URLSession.shared.dataTask(with: trekKaartURL!){(data, response, error) in
            
            let jsondecoder = JSONDecoder()
            
            if let data = data,
                let drawCard = try? jsondecoder.decode(DrawCard.self, from:data){
                completion(drawCard)
            } else {
                print("Either no data was returned, or data was not properly decoded.")
                completion(nil)
            }
        }
        task.resume()
    }
}


struct Deck: Codable{
    var success:Bool = false
    var deckID: String = ""
    var shuffled: Bool = false
    var remaining: Int = 0
    
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


