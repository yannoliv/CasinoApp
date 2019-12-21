//
//  BetControllerViewController.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 10/12/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import UIKit

class BetViewController: UIViewController {

    // UI elementen
    @IBOutlet weak var lblBetAmount: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    
    // Constanten
    let valueWhiteChip = 1
    let valueRedChip = 10
    let valueBlueChip = 20
    let valueBlackChip = 50
    let startInzet = 20
    
    // Nieuwe gebruiker aanmaken
    var gebruiker: Gebruiker = Gebruiker()
    
    // Standaard inzet
    var inzet : Int = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gebruiker inlezen, hoeveel inzet heeft hij nog, ..
        self.retrieveData()
        
        // Initialiseer de view, zien dat de labels goed staan, ...
        zetStartInzet()
    }
    
    @IBAction func clickedVerwijderInzet(_ sender: Any) {
        // inzet komt terug op de standaard inzet, en de gebruiker krijgt zijn inzet terug.
        gebruiker.currency += inzet
        zetStartInzet()
        refresh()
    }
    
    @IBAction func clickedWhitePokerChip(_ sender: UIImageView!) {
        guard gebruiker.currency - valueWhiteChip >= 0 else {showPopup(); return}
        self.gebruiker.currency -= valueWhiteChip
        self.inzet += valueWhiteChip
        refresh()
    }

    @IBAction func clickedRedPokerChip(_ sender: Any) {
        guard gebruiker.currency - valueRedChip >= 0 else {showPopup(); return}
        self.gebruiker.currency -= valueRedChip
        self.inzet += valueRedChip
        refresh()
    }
    
    @IBAction func clickedBluePokerChip(_ sender: Any) {
        guard gebruiker.currency - valueBlueChip >= 0 else {showPopup(); return}
        self.gebruiker.currency -= valueBlueChip
        self.inzet += valueBlueChip
        refresh()
    }
    
    
    @IBAction func clickedBlackPokerChip(_ sender: Any) {
        guard gebruiker.currency - valueBlackChip >= 0 else {showPopup(); return}
        self.gebruiker.currency -= valueBlackChip
        self.inzet += valueBlackChip
        refresh()
    }
    
    func zetStartInzet(){
        gebruiker.currency -= startInzet
        inzet = startInzet
        refresh()
    }
    
    func refresh(){
        DispatchQueue.main.async {
            self.lblBetAmount.text = String(self.inzet)
            self.lblCurrency.text = String(self.gebruiker.currency)
        }
    }
    
    func showPopup(){
        // De gebruiker heeft geen geld meer over om in te zetten en klikt alsnog op een munt
        let alert = UIAlertController(title: "Opgelet", message: "Je hebt geen munten genoeg om in te zetten.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Oke", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Doorgaan naar de blackjack view controller.
        // Gebruiker moet meegegeven worden.
        if segue.destination is BlackjackViewController
        {
            let vc = segue.destination as? BlackjackViewController
            //vc?.gebruiker = self.gebruiker
            self.writeData()
            vc?.inzet = self.inzet
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
            self.gebruiker = decodedGebruiker
        }
    }
    

}
