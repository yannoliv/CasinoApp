//
//  MenuViewController.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 22/10/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import UIKit

class BlackjackViewController: UIViewController {
    
    // Knoppen
    @IBOutlet private var hitButton: HighlightButton!
    @IBOutlet weak var doubleButton: BlackjackButton!
    @IBOutlet weak var standButton: BlackjackButton!
    
    // Kaarten
    @IBOutlet weak var stackView: UIStackView!
    
    // Labels
    @IBOutlet weak var lblPuntenGebruiker: UILabel!
    @IBOutlet weak var lblCurrencyGebruiker: UILabel!
    
    // Mee gekregen van BetViewController
    public var gebruiker: Gebruiker = Gebruiker()
    public var inzet: Int = 0
    
    // Lokale variableen
    private var deckID: String=""
    private var kaartenSpeler: [Card] = []
    
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Alle labels correct zetten
        refresh()
        
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
                    self.voegKaartToe(code: drawCard.cards[0].code)
                }
            }
        }
    }
    
    @IBAction func dealTapped(_ sender: HighlightButton) {
        // Knop deal. Moet een kaart trekken vanuit de stapel.
        hitButton.shake()
        self.fetchKaart{
            (drawCard) in
            guard let drawCard = drawCard else {return}
            
            DispatchQueue.main.async {
                // button disablen na 1x klikken voor een second, spamprevention
                self.hitButton.isEnabled = false
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { timer in
                    self.hitButton.isEnabled = true
                })
                self.voegKaartToe(code: drawCard.cards[0].code)
                if(Int(self.puntenVanKaarten())! >= 21){
                    self.spelerIsKlaar()
                }
                //self.labelPuntenSpeler.text = self.puntenVanSpeler()
            }
        }
    }
    
    // Eén kaart toevoegen in de stackview
    func voegKaartToe(code: String){
        let nieuweKaart = UIImage(named:"kaarten/\(code)")
        guard nieuweKaart != nil else {return}
        
        DispatchQueue.main.async {
            // Kaart aanmaken
            let kaartView = UIImageView(image: nieuweKaart!)
            // Centreren van kaarten
            kaartView.frame = CGRect(x: CGFloat(-40 + self.kaartenSpeler.count * 40 + Int(self.stackView.center.x)), y: 0, width: 80, height: 123)
            
            // Animeren van de toevoeging
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                // Kaart bij stackview steken
                self.stackView.center.x -= 20
                self.stackView.addSubview(kaartView)
            }, completion: nil)
        }
        refresh()
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
                //print(drawCard.cards[0])
                completion(drawCard)
            } else {
                print("Either no data was returned, or data was not properly decoded.")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func refresh(){
        DispatchQueue.main.async {
            // Alle labels correct zetten
            self.lblPuntenGebruiker.text = self.puntenVanKaarten()
            let currencyString = String(self.inzet)
            self.lblCurrencyGebruiker.text = currencyString
        }
    }
    
    func puntenVanKaarten() -> String{
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
        
    // Finished game
    func spelerIsKlaar(){
        self.hitButton.isHidden = true
        self.doubleButton.isHidden = true
        self.standButton.isHidden = true
    }
    
    @IBAction func doubleUp(_ sender: BlackjackButton) {
        
    }
    
    
    @IBAction func stand(_ sender: BlackjackButton) {
        
    }
    
    func split() {}
    
    func insurance() {}
    
    func surrender() {}
    
}
