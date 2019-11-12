//
//  MenuViewController.swift
//  WarCardGame
//
//  Created by Yannick Olivier on 22/10/2019.
//  Copyright © 2019 Yannick Olivier. All rights reserved.
//

import UIKit

class BlackjackViewController: UIViewController {
    
    @IBOutlet private var topCustomButton: NieuweButton!
    var bottomCustomButton = NieuweButton()
    
    @IBOutlet weak var leftImageView: UIImageView!
    
    @IBOutlet weak var rightImageView: UIImageView!
    
    
    @IBOutlet weak var leftScoreLabel: UILabel!
    
    
    @IBOutlet weak var rightScoreLabel: UILabel!
    
    var scorePlayer : Int = 0
    var scoreDealer : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.initialiseerDeck()
        leftScoreLabel.text = String(scorePlayer)
        rightScoreLabel.text = String(scoreDealer)
        
    }
    
    @IBAction func dealTapped(_ sender: Any) {
        
        let leftSide: Int = Int.random(in: 2..<14)
        let rightSide: Int = Int.random(in: 2..<14)
        
        leftImageView.image = UIImage(named: "card\(leftSide)")
        
        rightImageView.image = UIImage(named: "card\(rightSide)")
        
        if(leftSide > rightSide){
            scorePlayer+=1
            leftScoreLabel.text = String(scorePlayer)
            
        } else if(leftSide < rightSide){
            scoreDealer+=1
            rightScoreLabel.text = String(scoreDealer)
            
        }else{
            // POPUP
            let alertController = UIAlertController(title: "Tie screen", message:
                "There is a tie!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func topButtonTapped(_ sender: NieuweButton) {
        topCustomButton.shake()
    }
    
    func initialiseerDeck(){
        let deckURL = URL(string: "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1")!
        
        let task = URLSession.shared.dataTask(with: deckURL){(data, response, error) in
            
            let jsondecoder = JSONDecoder()
            
            if let data = data,
                let deck = try? jsondecoder.decode(Deck.self, from:data){
                print(deck)
            }
        }
        
        task.resume()
    }
    
}


struct Deck: Codable{
    var success:Bool = false
    var deckID: String = ""
    var shuffled: Bool = false
    var remaining: Int = 0
    
    enum CodingKeys: String, CodingKey{
        case success, deckID="deck_id", shuffled, remaining
    }
    
    init(from decoder: Decoder) throws{
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try valueContainer.decode(Bool.self, forKey: CodingKeys.success)
        self.deckID = try valueContainer.decode(String.self, forKey: CodingKeys.deckID)
        self.shuffled = try valueContainer.decode(Bool.self, forKey: CodingKeys.shuffled)
        self.remaining = try valueContainer.decode(Int.self, forKey: CodingKeys.remaining)
    }
}


