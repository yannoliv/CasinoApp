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
    
    // Variabelen
    var gebruiker: Gebruiker = Gebruiker()
    var inzet : Int = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zetStartInzet()
        refresh()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickedVerwijderInzet(_ sender: Any) {
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
        let alert = UIAlertController(title: "Opgelet", message: "Je hebt geen munten genoeg om in te zetten.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Oke", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is BlackjackViewController
        {
            let vc = segue.destination as? BlackjackViewController
            vc?.gebruiker = self.gebruiker
        }
    }
    

}
