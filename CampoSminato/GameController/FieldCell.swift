//
//  FieldCell.swift
//  CampoSminato
//
//  Created by Paolo Esposito on 16/09/2020.
//  Copyright © 2020 Paolo Esposito. All rights reserved.
//
//  This is the class for the GameViewController Cell:
//
//  It includes a label for counting adiacent bombs.
//  Inherits the peculiarities of the data model.
//  It manages the cells background colors, based on the state of the field.


import Foundation
import UIKit

class FieldCell: UICollectionViewCell {
    var adiacentBombsCount: Int = 0
    var status: UIColor = .darkGray
    var discovered: Bool = false
    let bomb: Bool = false
    var unknown: Bool = true
    var contentVisible: Bool = true
    var contentCellLabel: UILabel = UILabel()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        adiacentBombsCount = 0;
        setUnknown()
        contentView.backgroundColor = .clear
        // Number that display the adiacent bombs
        contentCellLabel = UILabel()
        contentCellLabel.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        contentCellLabel.textAlignment = .center
        addSubview(contentCellLabel)
        setContentVisible(contentVisible: false)
    }

    override func prepareForReuse() {
        setNeedsLayout()
        super.prepareForReuse()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAdiacentBombsCount(adiacentBombsCount: Int) {
        if bomb {return}
        self.adiacentBombsCount = adiacentBombsCount
        self.contentCellLabel.text = String(adiacentBombsCount)
    }

    func setBomb(bomb: Bool){
        if (bomb) {
            self.contentCellLabel.text = "B"
        }
    }

    
    func setUnknown() {
        self.backgroundColor = .darkGray
    }
    
    func setDiscovered(discovered: Bool){
        if(discovered){
            // the numbers
            unknown = false
            self.backgroundColor = .lightGray
            self.isUserInteractionEnabled = false;
            status = self.backgroundColor!
        }else{
            self.backgroundColor = status
        }
        self.discovered = discovered
        setContentVisible(contentVisible: self.discovered)
    }

    func showBomb(show: Bool){
        if(show){
            self.backgroundColor = .red
        }else{
            self.backgroundColor = self.status
        }
    }
    
    func setContentVisible(contentVisible: Bool){
        self.contentVisible = contentVisible
        self.contentCellLabel.isHidden = !contentVisible
    }

}
