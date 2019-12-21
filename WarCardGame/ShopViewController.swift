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
    @IBOutlet weak var lblCurrencyGebruiker: UILabel!
    
    
    // De gebruiker
    var gebruiker: Gebruiker = Gebruiker()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data opvangen
        self.retrieveData()
        
        initialiseerOpmaak()
    }
    
    func initialiseerOpmaak(){
        opmaakKist()
        lblCurrencyGebruiker.text = String(self.gebruiker.currency)
    }
    
    func opmaakKist(){
        // achtergrond
        self.kistEen.layer.cornerRadius = 8.0
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = kistEen.bounds
        gradientLayer.colors = [#colorLiteral(red: 1, green: 0.7834797502, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.653520976, blue: 0, alpha: 1).cgColor]
        gradientLayer.shouldRasterize = true
        kistEen.layer.insertSublayer(gradientLayer, at: 0)
        // button
        self.KoopEen.layer.cornerRadius = 8.0
    }
    
    @IBAction func koopEersteKist(_ sender: Any) {
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
