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
        print("viewDidLoad blackjack")
        
        // Meteen als de view laadt, de huidige currency schrijven naar bestand
        // Als de gebruiker dan slechte kaarten krijgt, en weg navigeert, is hij
        // toch zijn inzet kwijt.
        self.writeData()
        
        // Double up button moet weg indien geen geld genoeg
        if(self.gebruiker.currency - self.inzet < 0){
            self.doubleButton.isHidden = true
        }
        
        // Alle labels correct zetten
        refresh()
        
        // Deck aanmaken
        initialiseerDeck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear blackjack")
        refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("view will disappear")
        self.writeData()
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
    
    func schakelSpelerInputUit(){
        // Knopjes uitschakelen
        self.hitButton.isHidden = true
        self.doubleButton.isHidden = true
        self.standButton.isHidden = true
    }
    
    func speelCPU(){
        print(Int(puntenVanKaarten(kaarten: self.kaartenSpeler))!)
        print(Int(puntenVanKaarten(kaarten: self.kaartenCPU))!)
        while Int(puntenVanKaarten(kaarten: self.kaartenCPU))! < Int(puntenVanKaarten(kaarten: self.kaartenSpeler))!{
            // Trek kaarten tot de cpu gelijk of meer dan de speler heeft
            // while puntenVanKaarten(kaarten: self.kaartenCPU) < puntenVanKaarten(kaarten: self.kaartenSpeler) {
            print("in de while")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("in de dispatch")
                self.fetchKaart{
                    (drawCard) in
                    print("in de fetchkaart")
                    guard let drawCard = drawCard else {return}
                    // Kaart toevoegen
                    self.voegKaartToe(card: drawCard.cards[0], aanSpeler: false)
                }
            }
        }
        if(puntenVanKaarten(kaarten: self.kaartenCPU) < puntenVanKaarten(kaarten: self.kaartenSpeler)){
            eindeSpel(isGewonnen: true)
        } else{
            eindeSpel(isGewonnen: false)
        }
    }
    
    func eindeSpel(isGewonnen: Bool){
        schakelSpelerInputUit()
        
        // De gebruiker zijn currency is al reeds vermindert met de inzet.
        // Wat nu moet gebeuren is dat verlies ongedaan maken, PLUS
        // de inzet erbij optellen. Wat resulteert in 2x inzet
        if(isGewonnen) { self.gebruiker.currency += self.inzet * 2 }
        writeData()
        
        // Alert met als inhoud de gebruiker gewonnen of verloren is
        // Optie om te navigeren naar home of om opnieuw te gokken.
        let gewonnenString: String = isGewonnen ? "gewonnen!" : "verloren."
        let bericht: String = "Het spel is voltooid, je bent \(gewonnenString) Je hebt \(self.inzet) muntjes \(gewonnenString)"
        let alert = UIAlertController(title: "Status", message: bericht, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Home", style: .default, handler: { action in
            //self.tabBarController?.selectedIndex = 1
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true);
        }))
        alert.addAction(UIAlertAction(title: "Opnieuw", style: .cancel, handler: { action in
            print("opnieuw")
            self.dismiss(animated: true, completion: {});
            self.navigationController?.popViewController(animated: true);
        }))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.present(alert, animated: true)
        }
        
    }
    
    @IBAction func doubleUp(_ sender: BlackjackButton) {
        
        // Nog 1 kaart trekken en dan is het spel klaar
        self.fetchKaart{
            (drawCard) in
            guard let drawCard = drawCard else {return}
            self.voegKaartToe(card: drawCard.cards[0], aanSpeler: true)
        }
        
        // Inzet verdubbelen
        self.gebruiker.currency -= self.inzet
        self.inzet *= 2
        self.refresh()
        
        self.schakelSpelerInputUit()
        self.speelCPU()
    }
    
    
    @IBAction func stand(_ sender: BlackjackButton) {
        self.schakelSpelerInputUit()
        
        // CPU begint met spelen
        speelCPU()
    }
    
    func opnieuwSpelen(){
        // Alles opnieuw doen, met dezelfde inzet.
    }
    
    func initialiseerDeck(){
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
    
}
