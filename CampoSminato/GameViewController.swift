//
//  GameViewController.swift
//  CampoSminato
//
//  Created by Paolo Esposito on 15/09/2020.
//  Copyright © 2020 Paolo Esposito. All rights reserved.
//

import Foundation
import UIKit

class GameViewController : UIViewController, BoardDelegate {
    
    var myCollectionView:UICollectionView?
    //let field: Field?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView()
        view.backgroundColor = .white
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 60, height: 60)
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView?.backgroundColor = UIColor.white
        view.addSubview(myCollectionView ?? UICollectionView())
        
        self.view = view
    }
    
    // MARK: - Board Delegates
    
    func boardCell(_ cell: BoardCell?, didBecomeDiscoveredAt indexPath: IndexPath?) {
        <#code#>
    }
    
    func userFindBomb(at indexPath: IndexPath?) {
        <#code#>
    }
    
    func willWin() {
        <#code#>
    }
    
    func willLose() {
        <#code#>
    }
}
