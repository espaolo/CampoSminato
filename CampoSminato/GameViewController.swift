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
    var field = Field.init(width: 8, height: 8)
    var discoveredCells: Int = 0
    var firstLabel = UILabel()
    var secondLabel = UILabel()
    var timer: Timer? = nil
    var count: Int = 0 //countdown



    override func viewDidLoad() {
        super.viewDidLoad()
        //Reset Board and timer
        self.count = 60
        discoveredCells = 0
        field = Field.init(width: 8, height: 8)
        field.insertBombs(15)
        self.timer?.invalidate()
        self.timer = nil

        let view = UIView()
        view.backgroundColor = .clear
        field.delegate = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 1, bottom: 0, right: 1)
        layout.itemSize = CGSize(width: 44, height: 44)
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        let navigationBar = self.navigationController?.navigationBar
        let firstFrame = CGRect(x: navigationBar!.frame.width - 80, y: 0, width: 80, height: navigationBar!.frame.height)
        let secondFrame = CGRect(x: 8, y: 0, width: 80, height: navigationBar!.frame.height)
        firstLabel = UILabel(frame: firstFrame)
        secondLabel = UILabel(frame: secondFrame)

        firstLabel.text = "Score: 0"
        secondLabel.text = ""
        navigationBar!.addSubview(firstLabel)
        navigationBar!.addSubview(secondLabel)


        myCollectionView?.register(FieldCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView?.backgroundColor = UIColor.white
        myCollectionView?.dataSource = self
        myCollectionView?.delegate = self
        view.addSubview(myCollectionView!)
        
        self.view = view
//        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tickTimer), userInfo: nil, repeats: true)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if(self.count < 1) {
                timer.invalidate()
                self.timer = nil
                self.secondLabel.text = nil
                self.secondLabel.removeFromSuperview()
                self.timerElapsed()
            }
            else {
                self.count -= 1
                self.secondLabel.text = String(self.count)
            }

        }


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
    
    func discoveredCells(atIndexPaths indexPaths: [IndexPath]) {
        let score = discoveredCells + 1
        print (score)
        self.firstLabel.text = "Score: \(score)"
        discoveredCells = 0
        for indexPath in indexPaths {
            let currentCell = collectionView(myCollectionView!, cellForItemAt: indexPath) as! FieldCell
            if (currentCell.discovered) {
                discoveredCells += 1
            }
        }
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
        _ = (collectionView(myCollectionView!, cellForItemAt: indexPath!) as! FieldCell)
        myCollectionView?.reloadData()
        
        let allIndexPaths = (0..<myCollectionView!.numberOfSections).flatMap { section in
            return (0..<myCollectionView!.numberOfItems(inSection: section)).map { item in
                return IndexPath(item: item, section: section)
            }
        }
        discoveredCells(atIndexPaths: allIndexPaths)
    }
    
    func userFindBomb(at indexPath: IndexPath?) {
        (collectionView(myCollectionView!, cellForItemAt: indexPath!) as! FieldCell).contentView.backgroundColor = .red
        
    }
    
    func willWin() {
        print("User Win")
        let alert = UIAlertController(title: "You Win", message: "Congrats 🎉", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.firstLabel.text = nil
            self.secondLabel.text = nil
            self.viewDidLoad()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func willLose() {
        print("User Lose")
        let alert = UIAlertController(title: "You Lose", message: "Sorry there is a bomb! 💣", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.firstLabel.text = nil
            self.secondLabel.text = nil
            self.viewDidLoad()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func timerElapsed() {
        print("User Lose")
        let alert = UIAlertController(title: "You Lose", message: "Sorry time is running out ⏱", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.firstLabel.text = nil
            self.secondLabel.text = nil
            self.viewDidLoad()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
