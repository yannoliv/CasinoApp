//
//  BetControllerViewController.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 10/12/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import UIKit

class BetViewController: UIViewController {

    @IBOutlet weak var lblBetAmount: UILabel!
    
    @IBOutlet weak var lblCurrency: UILabel!
    
    let gebruiker: Gebruiker = Gebruiker(currency: 400)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickedVerwijderInzet(_ sender: Any) {
        DispatchQueue.main.async {
            self.lblBetAmount.text = String(20)
        }
    }
    
    @IBAction func clickedWhitePokerChip(_ sender: UIImageView!) {
        guard let betAmount = lblBetAmount.text else {return}
        
        DispatchQueue.main.async {
            self.lblBetAmount.text = String(Int(betAmount)! + 1)
        }
    }

    @IBAction func clickedRedPokerChip(_ sender: Any) {
        guard let betAmount = lblBetAmount.text else {return}
        
        DispatchQueue.main.async {
            self.lblBetAmount.text = String(Int(betAmount)! + 5)
        }
    }
    
    @IBAction func clickedBluePokerChip(_ sender: Any) {
        guard let betAmount = lblBetAmount.text else {return}
        
        DispatchQueue.main.async {
            self.lblBetAmount.text = String(Int(betAmount)! + 25)
        }
    }
    
    
    @IBAction func clickedBlackPokerChip(_ sender: Any) {
        guard let betAmount = lblBetAmount.text else {return}
        
        DispatchQueue.main.async {
            self.lblBetAmount.text = String(Int(betAmount)! + 50)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
