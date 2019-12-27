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
    
    @IBOutlet weak var homeButton: BlackjackButton!
    @IBOutlet weak var opnieuwButton: HighlightButton!
    @IBOutlet weak var koopExtraCoins: UIButton!
    @IBOutlet weak var uitslagStackView: UIStackView!
    
    // Kaarten
    @IBOutlet weak var stackViewSpeler: UIStackView!
    @IBOutlet weak var stackViewCPU: UIStackView!
    
    // Labels
    @IBOutlet weak var lblPuntenGebruiker: UILabel!
    @IBOutlet weak var lblCurrencyGebruiker: UILabel!
    @IBOutlet weak var lblInzetGebruiker: UILabel!
    
    @IBOutlet weak var lblUitslag: UILabel!
    
    // Mee gekregen van BetViewController
    public var gebruiker: Gebruiker = Gebruiker()
    public var inzet: Int = 0
    
    // Lokale variabelen
    private var deckID: String=""
    private var kaartenSpeler: [Card] = []
    private var kaartenCPU: [Card] = []
    private var onzichtbareKaart: Card? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Meteen als de view laadt, de huidige currency schrijven naar bestand
        // Als de gebruiker dan slechte kaarten krijgt, en weg navigeert, is hij
        // toch zijn inzet kwijt.
        self.writeData()
        
        // Double up button moet weg indien geen geld genoeg
        if(self.gebruiker.currency - self.inzet < 0){
            self.doubleButton.isHidden = true
        }
        
        // Deck aanmaken
        initialiseerDeck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Alle labels correct zetten
        refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Als je opeens het spel afsluit, moet de score al geschreven worden,
        // zo voorkom je dat als iemand slechte kaarten heeft, hij gewoon het spel
        // afsluit en opnieuw de app opent.
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
        
        var nieuweKaart = UIImage(named:"kaarten/\(card.code)")
        if(self.kaartenCPU.count == 1 && aanSpeler == false){
            // Tweede kaart moet onzichtbaar zijn van de cpu!
            nieuweKaart = UIImage(named:"kaarten/card_back")
        }
        
        guard nieuweKaart != nil else {return}
        
        DispatchQueue.main.async {
            // Kaart aanmaken
            let kaartView = UIImageView(image: nieuweKaart!)
            // Centreren van kaarten
            if(aanSpeler){
                // SPELER zijn kaart
                self.kaartenSpeler.append(card)
                kaartView.frame = CGRect(x: self.kaartenSpeler.count * 40, y: 0, width: 80, height: 123)
                self.stackViewSpeler.addSubview(kaartView)
            } else{
                // CPU zijn kaarten werken anders, de eerste kaart moet zichtbaar zijn, en op positie
                // 40 staan, zijn tweede kaart moet eerst onzichtbaar zijn en op positie 80 staan
                // vanaf een derde kaart regelt de methode speelCPU() het, door die async problemen
                if(self.kaartenCPU.count == 1){
                    // kaart niet toevoegen in de view van de cpu. Dat gebeurt pas vanaf het aan de cpu
                    // zijn beurt is, dat het zichtbaar wordt. We slaan de kaart op in een locale
                    // variabele en voegen die later toe aan de stackview
                    self.onzichtbareKaart = card
                    kaartView.frame = CGRect(x: 80, y: 0, width: 80, height: 123)
                } else{
                    self.kaartenCPU.append(card)
                    kaartView.frame = CGRect(x: self.kaartenCPU.count * 40, y: 0, width: 80, height: 123)
                }
                self.stackViewCPU.addSubview(kaartView)
            }
            self.refresh()
        }
        usleep(300000)
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
            if(self.kaartenSpeler.count > 2){
                self.doubleButton.isHidden = true
            }
        }
        
        // Controleren of de speler nog geen 21 heeft, of meer!
        if(Int(self.puntenVanKaarten(kaarten: self.kaartenSpeler))! > 21){
            self.spelerIsKapot()
        } else if(Int(self.puntenVanKaarten(kaarten: self.kaartenSpeler))! == 21){
            self.speelCPU()
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
        self.toonVerborgenKaartCPU()
        eindeSpel(isGewonnen: false)
    }
    
    func schakelSpelerInputUit(){
        // Knopjes uitschakelen
        self.hitButton.isHidden = true
        self.doubleButton.isHidden = true
        self.standButton.isHidden = true
    }
    
    func speelCPU(){
        // Met behulp van de dispatchgroup kunnen we wachten op een asynchrone methode
        let dispatchGroupPlayCPU = DispatchGroup()
        
        // Toon kaart die verborgen is
        self.toonVerborgenKaartCPU()
        
        // Trek kaarten tot de cpu gelijk of meer dan de speler heeft
        while Int(puntenVanKaarten(kaarten: self.kaartenCPU))! < 17{
            
            dispatchGroupPlayCPU.enter()
            
            let oorspronkelijkeHoeveelheidKaartenCPU: Int = self.kaartenCPU.count
            
            // Eén kaart toevoegen
            self.fetchKaart{
                (drawCard) in
                guard let drawCard = drawCard else {return}
                let card = drawCard.cards[0]
                print(card)
                
                let nieuweKaart = UIImage(named:"kaarten/\(card.code)")
                guard nieuweKaart != nil else {return}
                self.kaartenCPU.append(card)

                DispatchQueue.main.async {
                    let kaartView = UIImageView(image: nieuweKaart!)
                    print(self.kaartenCPU.count)
                    kaartView.frame = CGRect(x: self.kaartenCPU.count * 40, y: 0, width: 80, height: 123)
                    self.stackViewCPU.addSubview(kaartView)
                }
                if((oorspronkelijkeHoeveelheidKaartenCPU + 1) == self.kaartenCPU.count){
                    dispatchGroupPlayCPU.leave()
                }
            }
            dispatchGroupPlayCPU.wait()
            usleep(300000)
        }
        if(Int(puntenVanKaarten(kaarten: self.kaartenCPU))! >= Int(puntenVanKaarten(kaarten: self.kaartenSpeler))!
            && Int(puntenVanKaarten(kaarten: self.kaartenCPU))! <= 21){
            eindeSpel(isGewonnen: false)
        } else{
            eindeSpel(isGewonnen: true)
        }
    }
    
    func toonVerborgenKaartCPU(){
        guard self.onzichtbareKaart != nil else {return}
        self.kaartenCPU.append(self.onzichtbareKaart!)
        DispatchQueue.main.async {
            
            // Eerste kaart vernieuwen
            let view = self.stackViewCPU.subviews[0]
            view.isHidden = true
            let nieuweKaart = UIImage(named:"kaarten/\(self.kaartenCPU[0].code)")
            let kaartView = UIImageView(image: nieuweKaart!)
            kaartView.frame = CGRect(x: 40, y: 0, width: 80, height: 123)
            self.stackViewCPU.addSubview(kaartView)
            
            // Tweede kaart vernieuwen
            let view2 = self.stackViewCPU.subviews[1]
            view2.isHidden = true
            let nieuweKaart2 = UIImage(named:"kaarten/\(self.kaartenCPU[1].code)")
            let kaartView2 = UIImageView(image: nieuweKaart2!)
            kaartView2.frame = CGRect(x: 80, y: 0, width: 80, height: 123)
            self.stackViewCPU.addSubview(kaartView2)
        }
    }
    
    func eindeSpel(isGewonnen: Bool){
        schakelSpelerInputUit()
        
        // De gebruiker zijn currency is al reeds vermindert met de inzet.
        // Wat nu moet gebeuren is dat verlies ongedaan maken, PLUS
        // de inzet erbij optellen. Wat resulteert in 2x inzet
        if(isGewonnen) {
            self.gebruiker.currency += self.inzet * 2
            
            // uitslag opslaan
            self.writeScore()
        }
        writeData()
        
        // uitslag tonen
        DispatchQueue.main.async {
            let gewonnenString: String = isGewonnen ? "gewonnen!" : "verloren."
            self.lblUitslag.text = "Het spel is voltooid, je bent \(gewonnenString) Je hebt \(self.inzet) muntjes \(gewonnenString)"
            self.lblUitslag.isHidden = false
            self.uitslagStackView.isHidden = false
            self.koopExtraCoins.isHidden = false
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
        if(Int(self.puntenVanKaarten(kaarten: self.kaartenSpeler))! > 21){
            self.spelerIsKapot()
            self.toonVerborgenKaartCPU()
        } else {
            self.speelCPU()
        }
    }
    
    
    @IBAction func stand(_ sender: BlackjackButton) {
        self.schakelSpelerInputUit()
        
        // CPU begint met spelen
        speelCPU()
    }
    
    @IBAction func homeButton(_ sender: Any) {
        print("home")
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func opnieuwButton(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func koopExtra(_ sender: Any) {
        
    }
    
    
    func initialiseerDeck(){
        
        self.fetchDeck{
            (deck) in
            guard let deck = deck else {return}
            print(deck)
            self.deckID = deck.deckID
        
            // 2 kaarten trekken speler
            for index in 1...4{
                
                self.fetchKaart{
                (drawCard) in
                    guard let drawCard = drawCard else {return}
                    self.voegKaartToe(card: drawCard.cards[0], aanSpeler: index<3)
                }
            }
        }
    }
    
    // gebruiker opslaan in document()
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
    
    // score printen in document()
    func writeScore(){
        
        // Oude highscore lijst ophalen
        var highscores: Array<Highscore> = []
        
        let documentsDirectory =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask).first!
        let archiveURL =
            documentsDirectory.appendingPathComponent("highscores").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedHighscores = try? Data(contentsOf: archiveURL),
            let decodedHighscores = try? propertyListDecoder.decode(Array<Highscore>.self, from: retrievedHighscores){
            highscores = decodedHighscores
        }

        // klaarmaken voor nieuwe score bij oude scores toe te voegen
        let propertyListEncoder = PropertyListEncoder()
        
        let highScore: Highscore = Highscore(tijdstip: Date.init(), scoreSpeler: Int(self.puntenVanKaarten(kaarten: self.kaartenSpeler))!, scoreCPU: Int(self.puntenVanKaarten(kaarten: self.kaartenCPU))!, inzet: self.inzet, gebruiker: self.gebruiker)
        
        // nieuwe score toevoegen
        highscores.append(highScore)
        print(highscores)
        let encodedScore = try? propertyListEncoder.encode(highscores)
        try? encodedScore?.write(to: archiveURL, options: .noFileProtection)
    }
    
}


/** NOTES **
 // Animation
 UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
    //Kaart bij stackview steken
    self.stackViewSpeler.center.x -= 20
 }, completion: nil)
 */
