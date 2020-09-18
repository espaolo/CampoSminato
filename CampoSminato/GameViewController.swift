//
//  GameViewController.swift
//  CampoSminato
//
//  Created by Paolo Esposito on 15/09/2020.
//  Copyright © 2020 Paolo Esposito. All rights reserved.
//

import Foundation
import UIKit

class GameViewController : UIViewController, BoardDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var myCollectionView:UICollectionView?
    let field = Field.init(width: 8, height: 8)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        field.insertBombs(5)
        let view = UIView()
        view.backgroundColor = .clear
        field.delegate = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
//        layout.itemSize = CGSize(width: 60, height: 60)
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)

        myCollectionView?.register(FieldCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView?.backgroundColor = UIColor.white
        myCollectionView?.dataSource = self
        myCollectionView?.delegate = self

        view.addSubview(myCollectionView!)
        
        self.view = view
    }
    
    // MARK: - Collection View Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.field.height
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return self.field.width
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let boardCell = field.boardCell(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! FieldCell
        
        
        if (boardCell!.status ==  BoardCell.BoardCellStatus.cellUncovered){
            cell.setDiscovered(discovered: true)
        }
        cell.setAdiacentBombsCount(adiacentBombsCount: boardCell!.adiacentBombs)
        cell.setBomb(bomb: boardCell!.isBomb())
        return cell;
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Cell: \(indexPath.section), \(indexPath.row)")
        field.tapCellAtIndexPath(path: indexPath)

        
    }

    func bombs(atIndexPaths indexPaths: [IndexPath], makeVisible visible: Bool) {
        for indexPath in indexPaths {
            (collectionView(myCollectionView!, cellForItemAt: indexPath) as! FieldCell).setContentVisible(contentVisible: visible)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        collectionView.setNeedsLayout()
        collectionView.setNeedsDisplay()
        let edge = Float((field.width + 1) * 2)
        let edge2 = Float(collectionView.frame.size.width) - edge
        let edge3 = Float(edge) / edge2
        //return CGSize(width: CGFloat(edge3), height: CGFloat(edge3))
        return CGSize(width: 40.625, height: 40.625)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 1, bottom: 0, right: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    
    
    
    // MARK: - Board Delegates
    
    func boardCell(_ cell: BoardCell?, didBecomeDiscoveredAt indexPath: IndexPath?) {
        print ("Discovered cell \(String(describing: cell?.positionInBoard?.description)) : \(cell!.adiacentBombs) ")
        let viewCell = (collectionView(myCollectionView!, cellForItemAt: indexPath!) as! FieldCell)
        //viewCell.setDiscovered(discovered: true)
        myCollectionView?.reloadData()
    }
    
    func userFindBomb(at indexPath: IndexPath?) {
        (collectionView(myCollectionView!, cellForItemAt: indexPath!) as! FieldCell).showBomb(show: true)
    }
    
    func willWin() {
        print("User Win")
    }
    
    func willLose() {
        print("User Lose")

    }
}
