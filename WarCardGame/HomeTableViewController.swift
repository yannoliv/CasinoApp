//
//  KnoppenTableViewController.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 05/11/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    // Telkens als de app opstart, een nieuwe gebruiker maken omdat we
    // niet te werk gaan met authenticatie.
    var gebruiker: Gebruiker = Gebruiker()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Gebruiker aanmaken en meegeven naar het inzetten
        if segue.destination is BetViewController
        {
            let vc = segue.destination as? BetViewController
            vc?.gebruiker = self.gebruiker
        }
    }
}
