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
    
    @IBOutlet weak var stackView: UIStackView!
    
    var deckID: String=""
    var totaalPuntenSpeler: Int = 0
    var totaalPuntenCPU: Int = 0
    var aantalKaarten: Int = 1
    
    
        
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
                
                /* button disablen na 1x klikken voor een second, spamprevention
                self.topCustomButton.isEnabled = false
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: Selector("enableButton"), userInfo: nil, repeats: false)
                */
                
                let nieuweKaart = UIImage(named:"kaarten/\(drawCard.cards[0].code)")
                let kaartView = UIImageView(image: nieuweKaart!)
                kaartView.frame = CGRect(x: self.aantalKaarten*40, y: 0, width: 80, height: 123)
                self.aantalKaarten+=1
                self.stackView.addSubview(kaartView)
                
                UIView.animate(withDuration: 0.75, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    
                    self.stackView.center.x -= 20
                
                }, completion: nil)
                
                //self.view.addSubview(kaartView);
            }
        }
        
        
    }
    
    // button enabelen
    func enableButton(){
        self.topCustomButton.isEnabled = true
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
    
    func puntenVanKaart(card: Card) -> Int{
        let value: String = card.value
        var punten: Int = 0
        
        switch value {
        case "JACK", "QUEEN", "KING":
            punten = 10
        case "ACE":
            punten = 11
        default:
            punten = Int(value)!
        }
        return punten
    }
    
    func doubleUp() {}
    
    func split() {}
    
    func insurance() {}
    
    func surrender() {}
    
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


