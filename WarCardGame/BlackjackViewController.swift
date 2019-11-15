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
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var labelPuntenSpeler: UILabel!
    
    var deckID: String=""
    var kaartenSpeler: [Card] = []
    
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Deck aanmaken
        self.fetchDeck{
            (deck) in
            guard let deck = deck else {return}
            print(deck)
            self.deckID = deck.deckID
            
            // 2 kaarten trekken speler
            for _ in 1...2{
                self.fetchKaart{
                    (drawCard) in
                    guard let drawCard = drawCard else {return}
                    DispatchQueue.main.async {
                        self.voegKaartToe(code: drawCard.cards[0].code)
                        //self.labelPuntenSpeler.text = self.puntenVanSpeler()
                    }
                }
            }
        }
    }
    
    @IBAction func dealTapped(_ sender: NieuweButton) {
        topCustomButton.shake()
        
        self.fetchKaart{
            (drawCard) in
            guard let drawCard = drawCard else {return}
            
            DispatchQueue.main.async {
                // button disablen na 1x klikken voor een second, spamprevention
                self.topCustomButton.isEnabled = false
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { timer in
                    self.topCustomButton.isEnabled = true
                })
                self.voegKaartToe(code: drawCard.cards[0].code)
                //self.labelPuntenSpeler.text = self.puntenVanSpeler()
            }
        }
    }
    
    // Eén kaart toevoegen in de stackview
    func voegKaartToe(code: String){
        let nieuweKaart = UIImage(named:"kaarten/\(code)")
        guard nieuweKaart != nil else {return}
        
        let kaartView = UIImageView(image: nieuweKaart!)
        kaartView.frame = CGRect(x: -20 + self.kaartenSpeler.count*40, y: 0, width: 80, height: 123)
        self.stackView.addSubview(kaartView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.stackView.center.x -= 20
        }, completion: nil)
        
        print(self.puntenVanSpeler())
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
    func fetchKaart(completion: @escaping(DrawCard?) -> Void){
            
        let trekKaartURL = URL(string : "https://deckofcardsapi.com/api/deck/\(self.deckID)/draw/?count=1")
        
        let task = URLSession.shared.dataTask(with: trekKaartURL!){(data, response, error) in
            
            let jsondecoder = JSONDecoder()
            
            if let data = data,
                let drawCard = try? jsondecoder.decode(DrawCard.self, from:data){
                self.kaartenSpeler.insert(drawCard.cards[0], at: 0)
                print(drawCard.cards[0])
                completion(drawCard)
            } else {
                print("Either no data was returned, or data was not properly decoded.")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func puntenVanSpeler() -> String{
        var totaal: Int = 0
        var heeftAce: Bool = false
        
        for index in self.kaartenSpeler{
            let value: String = index.value
            switch value {
            case "JACK", "QUEEN", "KING":
                totaal += 10
            case "ACE":
                totaal += 1
                heeftAce = true
            default:
                totaal += Int(value)!
            }
        }
        if(totaal <= 11 && heeftAce){
            totaal += 10
        }
        return "\(totaal)"
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
