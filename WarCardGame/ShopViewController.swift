//
//  ShopViewController.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 21/12/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import UIKit


class ShopViewController: UIViewController {

    @IBOutlet weak var kistEen: UIView!
    @IBOutlet weak var KoopEen: UIButton!
    
    
    @IBOutlet weak var kistTwee: UIView!
    @IBOutlet weak var koopTwee: UIButton!
    
    @IBOutlet weak var kistDrie: UIView!
    @IBOutlet weak var koopDrie: UIButton!
    
    
    @IBOutlet weak var lblCurrencyGebruiker: UILabel!
    
    
    // De gebruiker
    var gebruiker: Gebruiker = Gebruiker()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data opvangen
        print("viewLoad")
        self.refresh()
        
        initialiseerOpmaak()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear blackjack")
        refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("view will disappear")
        self.retrieveData()
    }
    
    func initialiseerOpmaak(){
        opmaakKist()
        lblCurrencyGebruiker.text = String(self.gebruiker.currency)
    }
    
    func opmaakKist(){
        /** Kist Eén **/
        // achtergrond
        self.kistEen.layer.cornerRadius = 8.0
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = kistEen.bounds
        gradientLayer.cornerRadius = 8.0
        gradientLayer.colors = [#colorLiteral(red: 1, green: 0.7834797502, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.653520976, blue: 0, alpha: 1).cgColor]
        gradientLayer.shouldRasterize = true
        kistEen.layer.insertSublayer(gradientLayer, at: 0)
        // button
        self.KoopEen.layer.cornerRadius = 8.0
        
        /** Kist Twee **/
        // achtergrond
        self.kistTwee.layer.cornerRadius = 8.0
        let gradientLayerTwee = CAGradientLayer()
        gradientLayerTwee.frame = kistTwee.bounds
        gradientLayerTwee.cornerRadius = 8.0
        gradientLayerTwee.colors = [#colorLiteral(red: 0.2232716182, green: 0.7649561216, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0.0646671661, green: 0.653520976, blue: 0.4166845034, alpha: 1).cgColor]
        gradientLayerTwee.shouldRasterize = true
        kistTwee.layer.insertSublayer(gradientLayerTwee, at: 0)
        
        // Glowing effect
        kistTwee.layer.shadowOffset = .zero
        kistTwee.layer.shadowColor = UIColor.yellow.cgColor
        kistTwee.layer.shadowRadius = 20
        kistTwee.layer.shadowOpacity = 1
        kistTwee.layer.shadowPath = UIBezierPath(rect: kistTwee.bounds).cgPath
        
        // button
        self.koopTwee.layer.cornerRadius = 8.0
        
        /** Kist Drie **/
        // achtergrond
        self.kistDrie.layer.cornerRadius = 8.0
        let gradientLayerDrie = CAGradientLayer()
        gradientLayerDrie.frame = kistDrie.bounds
        gradientLayerDrie.cornerRadius = 8.0
        gradientLayerDrie.colors = [#colorLiteral(red: 0, green: 0.7113923373, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.01206656678, green: 0.4018086473, blue: 1, alpha: 1).cgColor]
        gradientLayerDrie.shouldRasterize = true
        kistDrie.layer.insertSublayer(gradientLayerDrie, at: 0)
        // button
        self.koopDrie.layer.cornerRadius = 8.0
    }
    
    @IBAction func koopEersteKist(_ sender: Any) {
        self.gebruiker.currency += 250
        self.writeData()
        self.refresh()
    }
    
    
    @IBAction func koopTweedeKist(_ sender: Any) {
        self.gebruiker.currency += 550
        self.writeData()
        self.refresh()
    }
    
    
    @IBAction func koopDerdeKist(_ sender: Any) {
        self.gebruiker.currency += 900
        self.writeData()
        self.refresh()
    }
    
    func refresh(){
        self.retrieveData()
        self.lblCurrencyGebruiker.text = "\(self.gebruiker.currency)"
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
