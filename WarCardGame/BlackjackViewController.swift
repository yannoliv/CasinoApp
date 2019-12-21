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
    @IBOutlet weak var stackViewSpeler: UIStackView!
    @IBOutlet weak var stackViewCPU: UIStackView!
    
    // Labels
    @IBOutlet weak var lblPuntenGebruiker: UILabel!
    @IBOutlet weak var lblCurrencyGebruiker: UILabel!
    @IBOutlet weak var lblInzetGebruiker: UILabel!
    
    // Mee gekregen van BetViewController
    public var gebruiker: Gebruiker = Gebruiker()
    public var inzet: Int = 0
    
    // Lokale variableen
    private var deckID: String=""
    private var kaartenSpeler: [Card] = []
    private var kaartenCPU: [Card] = []
    
        
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
                    self.voegKaartToe(card: drawCard.cards[0], aanSpeler: true)
                }
            }
            
            // 2 kaarten trekken cpu
            for _ in 1...2{
                self.fetchKaart{
                    (drawCard) in
                    guard let drawCard = drawCard else {return}
                    self.voegKaartToe(card: drawCard.cards[0], aanSpeler: false)
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
                
                // Kaart toevoegen
                self.voegKaartToe(card: drawCard.cards[0], aanSpeler: true)
            }
        }
    }
    
    // Eén kaart toevoegen in de stackview van de speler
    func voegKaartToe(card: Card, aanSpeler: Bool){
        
        let nieuweKaart = UIImage(named:"kaarten/\(card.code)")
        guard nieuweKaart != nil else {return}
        
        DispatchQueue.main.async {
            // Kaart aanmaken
            let kaartView = UIImageView(image: nieuweKaart!)
            // Centreren van kaarten
            if(aanSpeler){
                self.kaartenSpeler.append(card)
                kaartView.frame = CGRect(x: CGFloat(-40 + self.kaartenSpeler.count * 40 + Int(self.stackViewSpeler.center.x)), y: 0, width: 80, height: 123)
                
                // Animeren van de toevoeging
                UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    // Kaart bij stackview steken
                    self.stackViewSpeler.center.x -= 20
                    self.stackViewSpeler.addSubview(kaartView)
                }, completion: nil)
            } else{
                self.kaartenCPU.append(card)
                kaartView.frame = CGRect(x: CGFloat(-40 + self.kaartenCPU.count * 40 + Int(self.stackViewCPU.center.x)), y: 0, width: 80, height: 123)
                
                // Animeren van de toevoeging
                UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    // Kaart bij stackview steken
                    self.stackViewCPU.center.x -= 20
                    self.stackViewCPU.addSubview(kaartView)
                }, completion: nil)
            }
            self.refresh()
        }
    }
    
    
    // Deck ophalen. Hiervan hebben we de ID nodig: deckID
    func fetchDeck(completion: @escaping(Deck?) -> Void){
        let deckURL = URL(string: "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=6")!
        
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
            self.lblPuntenGebruiker.text = self.puntenVanKaarten(kaarten: self.kaartenSpeler)
            let inzetString = String(self.inzet)
            self.lblInzetGebruiker.text = inzetString
            let currencyString = String(self.gebruiker.currency)
            self.lblCurrencyGebruiker.text = currencyString
        }
        
        // Controleren of de speler nog geen 21 heeft, of meer!
        if(Int(self.puntenVanKaarten(kaarten: self.kaartenSpeler))! > 21){
            self.spelerIsKapot()
        } else if(Int(self.puntenVanKaarten(kaarten: self.kaartenSpeler))! == 21){
            self.spelerIsGewonnen()
        }
    }
    
    func puntenVanKaarten(kaarten: [Card]) -> String{
        var totaal: Int = 0
        var heeftAce: Bool = false
        
        for index in kaarten{
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
    
    func spelerIsGewonnen(){
        eindeSpel(isGewonnen: true)
    }
    
    func spelerIsKapot(){
        eindeSpel(isGewonnen: false)
    }
    
    func spelerIsKlaar(){
        // Knopjes uitschakelen
        self.hitButton.isHidden = true
        self.doubleButton.isHidden = true
        self.standButton.isHidden = true
        
        // CPU begint met spelen
        speelCPU()
    }
    
    func speelCPU(){
        // Trek kaarten tot de cpu gelijk of meer dan de speler heeft
    }
    
    func eindeSpel(isGewonnen: Bool){
        writeData()
        retrieveData()
        let gewonnenString: String = isGewonnen ? "gewonnen!" : "verloren."
        let bericht: String = "Het spel is voltooid, je bent \(gewonnenString) Je hebt \(self.inzet) muntjes \(gewonnenString)"
        let alert = UIAlertController(title: "Status", message: bericht, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Opnieuw", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Home", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func doubleUp(_ sender: BlackjackButton) {
        
        // Nog 1 kaart trekken en dan is het spel klaar
        self.fetchKaart{
            (drawCard) in
            guard let drawCard = drawCard else {return}
            self.voegKaartToe(card: drawCard.cards[0], aanSpeler: true)
        }
        
        // Inzet verdubbelen
        self.gebruiker.currency -= self.inzet * 2
        self.inzet *= 2
        
        self.refresh()
        
        self.spelerIsKlaar()
    }
    
    
    @IBAction func stand(_ sender: BlackjackButton) {
        self.spelerIsKlaar()
    }
    
    // score printen in document()
    func writeData(){
        let documentsDirectory =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask).first!
        let archiveURL =
            documentsDirectory.appendingPathComponent("gebruiker_historiek").appendingPathExtension("plist")
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedGebruiker = try? propertyListEncoder.encode(self.gebruiker)
        
        try? encodedGebruiker?.write(to: archiveURL, options: .noFileProtection)
    }
    
    // Score terug krijgen van gebruiker
    func retrieveData(){
        let documentsDirectory =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask).first!
        let archiveURL =
            documentsDirectory.appendingPathComponent("gebruiker_historiek").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedGebruiker = try? Data(contentsOf: archiveURL),
            let decodedGebruiker = try? propertyListDecoder.decode(Gebruiker.self, from: retrievedGebruiker){
            print(decodedGebruiker)
        }
    }
    
}
