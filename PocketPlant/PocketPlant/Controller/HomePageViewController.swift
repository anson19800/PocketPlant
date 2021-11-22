//
//  ViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit
import FirebaseAuth
import Lottie

enum HomePageButton: String, CaseIterable {
    case myPlant = "我的植物"
    case myFavorite = "最愛植物"
    case sharePlants = "共享植物"
    
    var icon: UIImage? {
        switch self {
        case .myPlant:
            return UIImage(systemName: "leaf.fill")
        case .myFavorite:
            return UIImage(systemName: "heart.fill")
        case .sharePlants:
            return UIImage(systemName: "leaf.arrow.triangle.circlepath")
        }
    }
}

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.autocapitalizationType = .none
            searchBar.placeholder = "搜尋"
            searchBar.backgroundImage = UIImage()
            searchBar.searchTextField.backgroundColor = .white
            searchBar.searchTextField.layer.cornerRadius = 15
            searchBar.searchTextField.layer.shadowColor = UIColor.black.cgColor
            searchBar.searchTextField.layer.shadowOffset = CGSize.zero
            searchBar.searchTextField.layer.shadowRadius = 4
            searchBar.searchTextField.layer.shadowOpacity = 0.1
        }
    }
    
    @IBOutlet weak var headerBackground: UIView! {
        didSet {
            headerBackground.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var plantCollectionView: UICollectionView!
    
    @IBOutlet weak var buttonCollectionView: UICollectionView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var qrcodeButton: UIButton!
    
    @IBOutlet weak var homeTitleLabel: UILabel!
    
    @IBOutlet weak var animationContainer: UIView!
    
    @IBOutlet weak var emptyPlantLabel: UILabel! {
        didSet {
            emptyPlantLabel.text = "還沒有紀錄任何植物呢\n快去新增吧！"
        }
    }
    
    var emptyAnimation: AnimationView?
    
    let firebaseManager = FirebaseManager.shared
    
    var plants: [Plant]? {
        didSet {
            checkIsEmpty()
        }
    }
    
    var blockView: VisitorBlockView?
    
    var searchPlants: [Plant]?
    
    var searching: Bool = false
    
    var isSelectedAt: HomePageButton = .myPlant
    
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var waterImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        plantCollectionView.delegate = self
        plantCollectionView.dataSource = self
        buttonCollectionView.delegate = self
        buttonCollectionView.dataSource = self
        searchBar.delegate = self
        buttonCollectionView.layer.masksToBounds = false
        
        buttonCollectionView.registerCellWithNib(
            identifier: String(describing: ButtonCollectionViewCell.self),
            bundle: nil)
        
        plantCollectionView.registerCellWithNib(
            identifier: String(describing: PlantCollectionViewCell.self),
            bundle: nil)
        
        buttonCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        
        updateMyPlants(withAnimation: false)
        
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        waterImageView.center = CGPoint(x: viewWidth - 50, y: viewHeight - 130)
        
        emptyAnimation = loadAnimation(name: "33731-emptyPlant", loopMode: .loop)
        if let emptyAnimation = emptyAnimation {
            emptyAnimation.frame = animationContainer.bounds
            animationContainer.addSubview(emptyAnimation)
            emptyAnimation.play()
        }
        
        self.hideKeyboardWhenTappedAround()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser == nil {
            
            self.homeTitleLabel.text = "歡迎"
            
            self.plants = []
            
            self.plantCollectionView.reloadData()
            
            if blockView == nil {
                
                blockView = addblockView()
                
            }
            
            return
            
        } else {
            
            if let blockView = blockView {
                
                blockView.removeFromSuperview()
                
                blockView.layoutIfNeeded()
                
                self.blockView = nil
                
            }
        }
        
        if let currentUser = UserManager.shared.currentUser,
           let userName = currentUser.name {
            self.homeTitleLabel.text = "歡迎\(userName)"
        } else {
            self.homeTitleLabel.text = "歡迎"
        }
        
        if Auth.auth().currentUser == nil {
            
            self.homeTitleLabel.text = "歡迎"
            
            self.plants = []
            
            self.plantCollectionView.reloadData()
            
            return
        }
        
        switch isSelectedAt {
            
        case .myPlant:
            
            updateMyPlants(withAnimation: false)
            
        case .myFavorite:
            
            updateMyFavoritePlants(withAnimation: false)
            
        case .sharePlants:
            
            updateSharePlants(withAnimation: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.searchBar.endEditing(true)
    }
    
    func updateMyPlants(withAnimation: Bool) {
        
        self.isSelectedAt = .myPlant
        
        firebaseManager.fetchPlants { result in
            
            switch result {
                
            case .success(let plants):
                
                self.plants = plants
                
                if withAnimation {
                
                    self.plantCollectionView.performBatchUpdates({
                        let indexSet = IndexSet(integersIn: 0...0)
                        self.plantCollectionView.reloadSections(indexSet)
                    }, completion: nil)
                    
                } else {
                    
                    self.plantCollectionView.reloadData()
                    
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func updateMyFavoritePlants(withAnimation: Bool) {
        
        self.isSelectedAt = .myFavorite
        
        firebaseManager.fetchFavoritePlants { result in
            
            switch result {
                
            case .success(let plants):
                
                self.plants = plants
                
                if withAnimation {
                    
                    self.plantCollectionView.performBatchUpdates({
                        let indexSet = IndexSet(integersIn: 0...0)
                        self.plantCollectionView.reloadSections(indexSet)
                    }, completion: nil)
                    
                } else {
                    
                    self.plantCollectionView.reloadData()
                    
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func updateSharePlants(withAnimation: Bool) {
        
        self.isSelectedAt = .sharePlants
        
        guard let currentUser = UserManager.shared.currentUser,
              let sharePlantsID = currentUser.sharePlants
        else {
            self.plants = []
            return
        }
        
        let group = DispatchGroup()
        
        self.plants = []
        
        sharePlantsID.forEach { plantID in
            
            group.enter()
            
            firebaseManager.fetchPlants(plantID: plantID) { result in
                switch result {
                case .success(let plant):
                    
                    if var plants = self.plants {
                        
                        plants.append(plant)
                        
                        self.plants = plants
                        
                        group.leave()
                        
                    } else {
                        
                        self.plants = [plant]
                        
                        group.leave()
                        
                    }
                    
                case .failure(let error):
                    print(error)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            
            if withAnimation {
            
                self.plantCollectionView.performBatchUpdates({
                    let indexSet = IndexSet(integersIn: 0...0)
                    self.plantCollectionView.reloadSections(indexSet)
                }, completion: nil)
                
            } else {
                
                self.plantCollectionView.reloadData()
                
            }
        }
    }
    
    func checkIsEmpty() {
        if let plants = plants {
            if plants.count <= 0 {
                animationContainer.isHidden = false
                emptyPlantLabel.isHidden = false
                waterImageView.isHidden = true
                switch isSelectedAt {
                case .myPlant:
                    emptyPlantLabel.text = "還沒有植物呢\n點擊畫面右上角＋新增！"
                case .myFavorite:
                    emptyPlantLabel.text = "還沒有最愛植物呢！"
                case .sharePlants:
                    emptyPlantLabel.text = "還沒有收藏植物呢\n快掃描朋友的植物QRCode!"
                }
                if let emptyAnimation = emptyAnimation {
                    emptyAnimation.play()
                }
            } else {
                animationContainer.isHidden = true
                emptyPlantLabel.isHidden = true
                waterImageView.isHidden = false
                if let emptyAnimation = emptyAnimation {
                    emptyAnimation.stop()
                }
            }
        } else {
            
            animationContainer.isHidden = false
            emptyPlantLabel.isHidden = false
            waterImageView.isHidden = true
            switch isSelectedAt {
            case .myPlant:
                emptyPlantLabel.text = "還沒有植物呢\n點擊畫面右上角＋新增！"
            case .myFavorite:
                emptyPlantLabel.text = "還沒有最愛植物呢！"
            case .sharePlants:
                emptyPlantLabel.text = "還沒有收藏植物呢\n快掃描朋友的植物QRCode!"
            }
            if let emptyAnimation = emptyAnimation {
                emptyAnimation.play()
            }
        }
        
        if isSelectedAt == .sharePlants {
            waterImageView.isHidden = true
        }
    }
    
    func deletePlantAction(indexPath: IndexPath) {
        
        guard var plants = plants else { return }
        
        let plant = plants[indexPath.row]
        
        plants.remove(at: indexPath.row)
        
        self.plants = plants

        firebaseManager.deletePlant(plant: plant) { isSuccess in
            if isSuccess {
                self.plantCollectionView.deleteItems(at: [indexPath])
            } else {
                self.showAlert(title: "Oops", message: "刪除的過程出了點問題，請再試一次", buttonTitle: "確認")
            }
        }
    }
    
    func deleteSharePlant(sharePlants: [String]) {
        UserManager.shared.deleteSharePlant(sharePlants: sharePlants) { isSuccess in
            if isSuccess {
                self.updateSharePlants(withAnimation: true)
            }
        }
    }
    
    func editPlantAction(indexPath: IndexPath) {
        
        guard let plants = plants else { return }
        
        let plant = plants[indexPath.row]
        
        performSegue(withIdentifier: "editPlant", sender: plant)
        
    }
    
    func deathPlantAction(indexPath: IndexPath) {
        
        guard let plants = plants else { return }
        
        let plant = plants[indexPath.row]
        
        performSegue(withIdentifier: "deathPlant", sender: plant)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if Auth.auth().currentUser == nil {
            
            showLoginAlert()
            
            return
            
        }
        
        switch segue.identifier {
            
        case "showPlantDetail":
            
            guard let destinationVC = segue.destination as? PlantDetailViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.plant = plant
            
        case "createPlant":
            
            guard let destinationVC = segue.destination as? NewPlantPageViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.pageMode = .create
            
            destinationVC.parentVC = self
            
        case "editPlant":
            
            guard let destinationVC = segue.destination as? NewPlantPageViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.pageMode = .edit(editedPlant: plant)
            
            destinationVC.parentVC = self
            
        case "deathPlant":
            
            guard let destinationVC = segue.destination as? DeathPlantViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.plant = plant

        default:
            
            break
        }
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
        guard let plants = plants else { return }
        
        if plants.count <= 0 {
            showAlert(title: "沒有植物", message: "沒有植物可以澆水，快去新增吧！", buttonTitle: "確定")
            return
        }
        
        let group = DispatchGroup()
        plants.forEach({ plant in
            group.enter()
            firebaseManager.updateWater(plant: plant) { isSuccess in
                if isSuccess {
                    group.leave()
                } else {
                    group.leave()
                }
            }
        })
        
        group.notify(queue: .main) {
            
            let dropAnimation = self.loadAnimation(name: "61313-waterDrop", loopMode: .playOnce)
            
            dropAnimation.contentMode = .scaleToFill
            
            dropAnimation.frame = self.view.frame
            
            self.view.addSubview(dropAnimation)
            
            dropAnimation.play() { _ in
                dropAnimation.removeFromSuperview()
            }
        }
//        showAlert(title: "全部澆水", message: "對畫面上所有植物澆水", buttonTitle: "確定")
    }
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        
        guard let dropView = sender.view else { return }
        
        UIView.animate(withDuration: 0.1) {() -> Void in
            dropView.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
        
        let translation = sender.translation(in: view)
        dropView.center.x += translation.x
        dropView.center.y += translation.y
        sender.setTranslation(.zero, in: view)
        
        let selectedPoint = dropView.convert(CGPoint.zero, to: self.plantCollectionView)
        
        if let indexPath = plantCollectionView.indexPathForItem(at: selectedPoint) {
            
            if let selectedCell = plantCollectionView.cellForItem(at: indexPath) as? PlantCollectionViewCell,
               let cells = plantCollectionView.visibleCells as? [PlantCollectionViewCell] {
                
                cells.forEach { cell in
                    if cell == selectedCell {
                        
                        cell.isPanOnCell = true
                        
                    } else {
                        
                        cell.isPanOnCell = false
                        
                    }
                }
            }
        } else {
            if let cells = plantCollectionView.visibleCells as? [PlantCollectionViewCell] {
                cells.forEach { cell in
                    cell.isPanOnCell = false
                }
            }
        }
        
        if sender.state == .ended {
            
            if let cells = plantCollectionView.visibleCells as? [PlantCollectionViewCell] {
                cells.forEach { cell in
                    cell.isPanOnCell = false
                }
            }
            
            dropView.isUserInteractionEnabled = false
            
            let point = dropView.convert(CGPoint.zero, to: self.plantCollectionView)
            
            UIView.animate(withDuration: 0.3) {
                dropView.transform = CGAffineTransform(rotationAngle: .pi / -4)
            }
            
            UIView.animate(withDuration: 0.3, delay: 0.5, animations: {
                
                dropView.transform = .identity
                
                let safeX = self.view.bounds.size.width - 50
                let safeY = self.view.bounds.size.height - 130
                
                dropView.center = CGPoint(x: safeX, y: safeY)
                
            }, completion: nil)
            
            if let indexPath = plantCollectionView.indexPathForItem(at: point),
               let plants = self.plants {
                
                let plantName = plants[indexPath.row].name
                
                firebaseManager.updateWater(plant: plants[indexPath.row]) { isSuccess in
                    
                    if isSuccess {
                        
                        dropView.isUserInteractionEnabled = true
                        
                        if let plantCell = self.plantCollectionView.cellForItem(at: indexPath) as? PlantCollectionViewCell {
                            
                            let dropAnimation = self.loadAnimation(name: "61313-waterDrop", loopMode: .playOnce)
                            
                            dropAnimation.frame = self.plantCollectionView.convert(plantCell.frame, to: self.view)
                            
                            dropAnimation.contentMode = .scaleToFill
                            
                            self.view.addSubview(dropAnimation)
                            
                            dropAnimation.bringSubviewToFront(plantCell)
                            
                            dropAnimation.play() { _ in
                                dropAnimation.removeFromSuperview()
                            }
                            
                        }
                        
                    }
                }
            } else {
                
                dropView.shake()
                
                dropView.isUserInteractionEnabled = true
            }
        }
    }
}

// MARK: - CollectionViewDelegate & CollectionViewDataSource
extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        searchBar.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == buttonCollectionView {
            
            return HomePageButton.allCases.count
            
        } else {
            
            if searching {
                
                guard let searchPlants = self.searchPlants else { return 0 }
                
                return searchPlants.count
                
            } else {
                
                guard let plants = self.plants else { return 0 }
                
                return plants.count
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == buttonCollectionView {
            
            let cell = buttonCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ButtonCollectionViewCell.self),
                for: indexPath
            )
            
            guard let buttonCell = cell as? ButtonCollectionViewCell else { return cell }
            
            let buttonType = HomePageButton.allCases[indexPath.row]
            
            let title = buttonType.rawValue
            
            if let iconImage = buttonType.icon {
                
                buttonCell.layoutCell(image: iconImage, title: title)
                
            }
            
            return buttonCell
            
        } else if collectionView == plantCollectionView {
            
            let cell = plantCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: PlantCollectionViewCell.self),
                for: indexPath
            )
            
            guard let plantCell = cell as? PlantCollectionViewCell else { return cell }
            
            if searching {
                
                guard let searchPlants = self.searchPlants
                else { return cell }
                
                let imageURL = searchPlants[indexPath.row].imageURL
                
                plantCell.layoutCell(imageURL: imageURL,
                                     name: searchPlants[indexPath.row].name)
                
                return plantCell
                
            } else {
                
                guard let plants = self.plants
                else { return cell }
                
                let imageURL = plants[indexPath.row].imageURL
                
                plantCell.layoutCell(imageURL: imageURL,
                                     name: plants[indexPath.row].name)
                
                return plantCell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSpace: CGFloat = 10
        let columCount: CGFloat = 3
        
        let plantWidth = floor((plantCollectionView.bounds.width - itemSpace * (columCount - 1)) / columCount )
        
        let buttonWidth = floor((buttonCollectionView.bounds.width - 35 * (columCount - 1)) / columCount )

        if collectionView == plantCollectionView {
            return CGSize(width: plantWidth, height: plantWidth * 1.2)
        } else {
            return CGSize(width: buttonWidth, height: 55)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.endEditing(true)
        
        if Auth.auth().currentUser == nil {
            
            showLoginAlert()
            
            return
            
        }
        
        if collectionView == plantCollectionView {
        
            guard let plants = self.plants else { return }
        
            let plant = plants[indexPath.row]
            
            tabBarController?.tabBar.isHidden = true
        
            performSegue(withIdentifier: "showPlantDetail", sender: plant)
            
        } else if collectionView == buttonCollectionView {
            
            let buttonType = HomePageButton.allCases[indexPath.row]
            
            switch buttonType {
                
            case .myPlant:
                
                if isSelectedAt == .myPlant {
                    
                    break
                    
                }
                
                updateMyPlants(withAnimation: true)
                
                self.isSelectedAt = .myPlant
                
            case .myFavorite:
                
                if isSelectedAt == .myFavorite {
                    
                    break
                    
                }
                
                searching = false
                
                updateMyFavoritePlants(withAnimation: true)
                
                isSelectedAt = .myFavorite
                
            case .sharePlants:
                
                if isSelectedAt == .sharePlants {
                    
                    break
                    
                }
                
                isSelectedAt = .sharePlants
                
                searching = false
                
                updateSharePlants(withAnimation: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard collectionView == plantCollectionView else { return nil }
        
        if isSelectedAt == .sharePlants {
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil) { _ in
                
                let deleteAction = UIAction(title: "取消收藏",
                                            image: UIImage(systemName: "trash"),
                                            attributes: .destructive) { _ in
                    if let currentUser = UserManager.shared.currentUser,
                       var sharePlants = currentUser.sharePlants{
                        
                        sharePlants.remove(at: indexPath.row)
                        
                        self.deleteSharePlant(sharePlants: sharePlants)
                        
                    }
                }
                
                return UIMenu(title: "", children: [deleteAction])
            }
        } else {
            
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil) { _ in
                
                let deleteAction = UIAction(title: "刪除",
                                            image: UIImage(systemName: "trash"),
                                            attributes: .destructive) { _ in
                    
                    self.deletePlantAction(indexPath: indexPath)
                    
                }
                
                let editAction = UIAction(title: "編輯", image: nil) { _ in
                    
                    self.editPlantAction(indexPath: indexPath)
                    
                }
                
                let deathAction = UIAction(title: "澆水紀錄", image: nil) { _ in
                    
                    self.deathPlantAction(indexPath: indexPath)
                    
                }
                
                return UIMenu(title: "", children: [editAction, deathAction, deleteAction])
            }
        }
    }
}

extension HomePageViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard let plants = plants else { return }
        
        if searchText != "" {
            
            searchPlants = plants.filter { plant -> Bool in
                
                return plant.name.contains(searchText)
                
            }
            
            searching = true
            
        } else {
            
            searching = false
            
        }
        
        self.plantCollectionView.performBatchUpdates({
            let indexSet = IndexSet(integersIn: 0...0)
            self.plantCollectionView.reloadSections(indexSet)
        }, completion: nil)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searching = false
        
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
    }
}
