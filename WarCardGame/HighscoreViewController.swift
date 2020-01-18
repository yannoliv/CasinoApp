//
//  HighscoreViewController.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 27/12/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import UIKit


class HighscoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var highscores: Array<Highscore> = []
    private var myTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        myTableView.register(HighscoreTableCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Nog voordat de view laad, moeten de highscores al geinitialiseerd worden.
        self.retrieveHighscores()
        self.myTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(self.highscores[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.highscores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath) as! HighscoreTableCell
        let currentLastItem = highscores[indexPath.row]
        cell.highscore = currentLastItem
        return cell
    }
    
    
    func retrieveHighscores(){
        
        let documentsDirectory =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask).first!
        let archiveURL =
            documentsDirectory.appendingPathComponent("highscores").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedHighscores = try? Data(contentsOf: archiveURL),
            let decodedHighscores = try? propertyListDecoder.decode(Array<Highscore>.self, from: retrievedHighscores){
            
            // Sorteren op hoogste inzet.
            self.highscores = decodedHighscores.sorted(by:{
                return $0.inzet > $1.inzet
            })
        }
    }

}
