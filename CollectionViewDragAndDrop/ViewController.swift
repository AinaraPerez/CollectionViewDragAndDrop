//
//  ViewController.swift
//  CollectionViewDragAndDrop
//
//  Created by Ainara Perez on 26/5/19.
//  Copyright © 2019 Ainara Perez. All rights reserved.
//

import UIKit

class MyCell: UICollectionViewCell {
    @IBOutlet weak var labelCell: UILabel!
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    @IBOutlet weak var myCollection: UICollectionView!
    
    var estimatedWidth = Int()
    let cellMarginSize = 8
    var infoCell = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsCollection()
        calculateGridView()
    }
    
    func settingsCollection() {
        myCollection.delegate = self
        myCollection.dataSource = self
        myCollection.dragInteractionEnabled = true
        myCollection.dragDelegate = self
        myCollection.dropDelegate = self
    }
    
    //3 cells per row
    func calculateGridView() {
        let screenSize = UIScreen.main.bounds
        let screenWidth: CGFloat = screenSize.width
        estimatedWidth = (Int(screenWidth) / 3) - (cellMarginSize * 2)
        let flow = myCollection.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }

    //COLLECTIONVIEW FUNCTIONS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCell
        cell.labelCell.text = infoCell[indexPath.row]
        customizeCell(cell: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: estimatedWidth, height: estimatedWidth)
    }
    
    //DRAG&DROP FUNCTIONS
    
    //when click in a cell
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = collectionView == myCollection ? infoCell[indexPath.row]: ""
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        if collectionView == myCollection {
            let previewParameters = UIDragPreviewParameters()
            previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: estimatedWidth, height: estimatedWidth))
            return previewParameters
        }
        return nil
    }
    
    //when the cell is dragged
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
    //when drop the cell
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        if coordinator.proposal.operation == .move {
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }
    func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= collectionView.numberOfItems(inSection: 0)
            {
                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }
            collectionView.performBatchUpdates({
                infoCell.remove(at: sourceIndexPath.row)
                infoCell.insert(item.dragItem.localObject as! String, at: dIndexPath.row)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [dIndexPath])
            })
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        }
    }
    
    //EXTRA
    func customizeCell(cell: MyCell){
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        cell.layer.cornerRadius = 10
    }
}

