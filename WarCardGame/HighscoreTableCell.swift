import UIKit
class HighscoreTableCell : UITableViewCell {
    
    /*
 Meer info op
     https://medium.com/@kemalekren/swift-create-custom-tableview-cell-with-programmatically-in-ios-835d3880513d
 */
    
    var highscore : Highscore? {
        didSet {
            lblGebruikersnaam.text = highscore!.gebruiker.naam
            lblGebruikersCurrency.text = "\(highscore!.gebruiker.currency)"
            lblInzet.text = "\(highscore!.inzet)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd,yyyy"
            lblTijdstip.text = "\(dateFormatter.string(from: highscore!.tijdstip))"
        }
    }
    
    
    private let lblGebruikersnaam : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    
    private let lblInzet : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    
    private let lblTijdstip : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    
    private let lblGebruikersCurrency : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    
    private let imgCoins : UIImageView = {
        let imgView = UIImageView(image: UIImage(named:"coins"))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        return imgView
    }()
    
    
    private let imgChips : UIImageView = {
        let imgView = UIImageView(image: UIImage(named:"stack_poker_chips"))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        return imgView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(lblGebruikersnaam)
        addSubview(lblInzet)
        addSubview(lblTijdstip)
        addSubview(lblGebruikersCurrency)
        addSubview(imgCoins)
        addSubview(imgChips)
        
        
        // INZET
        imgChips.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 9, paddingRight: 0, width: 24, height: 24, enableInsets: false)
        
        lblInzet.anchor(top: topAnchor, left: imgChips.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 60, height: 0, enableInsets: false)
        
        
        // Gebruiker
        lblGebruikersnaam.anchor(top: topAnchor, left: lblInzet.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0, enableInsets: false)
        
        imgCoins.anchor(top: lblGebruikersnaam.bottomAnchor, left: lblInzet.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 5, paddingBottom: 8, paddingRight: 0, width: 24, height: 24, enableInsets: false)
        
        lblGebruikersCurrency.anchor(top: lblGebruikersnaam.bottomAnchor, left: imgCoins.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        
        
        lblTijdstip.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 9, paddingBottom: 8, paddingRight: 8, width: 0, height: 60, enableInsets: false)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
