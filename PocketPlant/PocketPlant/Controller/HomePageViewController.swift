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
    
    var emptyText: String {
        switch self {
        case .myPlant:
            return "還沒有植物呢\n點擊畫面右上角＋新增！"
        case .myFavorite:
            return "還沒有最愛植物呢！"
        case .sharePlants:
            return "還沒有收藏植物呢\n快掃描朋友的植物QRCode!"
        }
    }
}

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.placeholder = "搜尋"
            searchBar.setTextFieldShadow()
            searchBar.backgroundImage = UIImage()
            searchBar.autocapitalizationType = .none
        }
    }
    
    @IBOutlet weak var headerBackground: UIView! {
        didSet {
            headerBackground.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var plantCollectionView: UICollectionView! {
        didSet {
            plantCollectionView.delegate = self
            plantCollectionView.dataSource = self
            plantCollectionView.registerCellWithNib(
                identifier: String(describing: PlantCollectionViewCell.self),
                bundle: nil)
        }
    }
    
    @IBOutlet weak var buttonCollectionView: UICollectionView! {
        didSet {
            buttonCollectionView.delegate = self
            buttonCollectionView.dataSource = self
            buttonCollectionView.layer.masksToBounds = false
            buttonCollectionView.registerCellWithNib(
                identifier: String(describing: ButtonCollectionViewCell.self),
                bundle: nil)
        }
    }
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var qrcodeButton: UIButton!
    
    @IBOutlet weak var homeTitleLabel: UILabel!
    
    @IBOutlet weak var animationContainer: UIView!
    
    @IBOutlet weak var emptyPlantLabel: UILabel! {
        didSet {
            emptyPlantLabel.text = "還沒有紀錄任何植物呢\n快去新增吧！"
        }
    }
    
    @IBOutlet weak var waterImageView: UIImageView!
    
    private var emptyAnimation: AnimationView?
    
    private let firebaseManager = FirebaseManager.shared
    
    private let userManager = UserManager.shared
    
    var plants: [Plant]? {
        didSet {
            checkIsEmpty()
        }
    }
    
    private var blockView: VisitorBlockView?
    
    private var searchedPlants: [Plant]?
    
    private var isSearching: Bool = false
    
    var selectionType: HomePageButton = .myPlant
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        buttonCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        
        updateMyPlants(withAnimation: false)
        
        waterImageView.center = CGPoint(x: view.bounds.width - 50, y: view.bounds.height - 130)
        
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
            
            if blockView == nil { blockView = addBlockView() }
            
            return
            
        } else {
            
            if let blockView = blockView {
                
                blockView.removeFromSuperview()
                
                blockView.layoutIfNeeded()
                
                self.blockView = nil
            }
        }
        
        if let currentUser = userManager.currentUser,
           let userName = currentUser.name {
            
            self.homeTitleLabel.text = "歡迎\(userName)"
            
        } else {
            
            self.homeTitleLabel.text = "歡迎"
        }
        
        switch selectionType {
            
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
        
        self.selectionType = .myPlant
        
        self.buttonCollectionView.isUserInteractionEnabled = false
        
        firebaseManager.fetchPlants(.myPlant) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                
            case .success(let plants):
                
                self.plants = plants
                
                if withAnimation {
                    
                    self.reloadCollectionViewInSection(self.plantCollectionView)
                    
                } else {
                    
                    self.plantCollectionView.reloadData()
                    
                }
                
                self.buttonCollectionView.isUserInteractionEnabled = true
                
            case .failure(let error):
                
                print(error)
                
                self.buttonCollectionView.isUserInteractionEnabled = true
            }
        }
    }
    
    private func updateMyFavoritePlants(withAnimation: Bool) {
        
        self.selectionType = .myFavorite
        
        self.buttonCollectionView.isUserInteractionEnabled = false
        
        firebaseManager.fetchPlants(.myFavorite) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let plants):
                
                self.plants = plants
                
                if withAnimation {
                    
                    self.reloadCollectionViewInSection(self.plantCollectionView)
                    
                } else {
                    
                    self.plantCollectionView.reloadData()
                }
                
                self.buttonCollectionView.isUserInteractionEnabled = true
                
            case .failure(let error):
                
                self.buttonCollectionView.isUserInteractionEnabled = true
                
                print(error)
            }
        }
    }
    
    private func updateSharePlants(withAnimation: Bool) {
        
        self.selectionType = .sharePlants
        
        self.buttonCollectionView.isUserInteractionEnabled = false
        
        guard let currentUser = userManager.currentUser,
              let sharePlantsID = currentUser.sharePlants
        else {
            self.plants = []
            return
        }
        
        let group = DispatchGroup()
        
        self.plants = []
        
        sharePlantsID.forEach { plantID in
            
            group.enter()
            
            firebaseManager.fetchPlants(plantID: plantID) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                    
                case .success(let plant):
                    
                    if self.plants != nil {
                        
                        self.plants?.append(plant)
                        
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
                
                self.reloadCollectionViewInSection(self.plantCollectionView)
                
            } else {
                
                self.plantCollectionView.reloadData()
                
            }
            
            self.buttonCollectionView.isUserInteractionEnabled = true
        }
    }
    
    private func reloadCollectionViewInSection(_ collectionView: UICollectionView) {
        
        collectionView.performBatchUpdates({
            
            let indexSet = IndexSet(integersIn: 0...0)
            
            collectionView.reloadSections(indexSet)
            
        }, completion: nil)
    }
    
    private func checkIsEmpty() {
        if let plants = plants {
            
            animationContainer.isHidden = !(plants.count <= 0)
            emptyPlantLabel.isHidden = !(plants.count <= 0)
            waterImageView.isHidden = (plants.count <= 0)
            
            if plants.count <= 0 {
                
                emptyPlantLabel.text = selectionType.emptyText
                
                emptyAnimation?.play()
                
            } else {
                
                emptyAnimation?.stop()
            }
            
        } else {
            
            animationContainer.isHidden = false
            emptyPlantLabel.isHidden = false
            waterImageView.isHidden = true
            
            emptyPlantLabel.text = selectionType.emptyText
            
            emptyAnimation?.play()
        }
        
        waterImageView.isHidden = (selectionType == .sharePlants)
    }
    
    private func deletePlantAction(indexPath: IndexPath) {
        
        guard var plants = plants else { return }
        
        let plant = plants[indexPath.row]
        
        plants.remove(at: indexPath.row)
        
        self.plants = plants

        firebaseManager.deletePlant(plant: plant) { [weak self] isSuccess in
            
            guard let self = self else { return }
            
            if isSuccess {
                
                self.plantCollectionView.deleteItems(at: [indexPath])
                
            } else {
                
                self.showAlert(title: "Oops", message: "刪除的過程出了點問題，請再試一次", buttonTitle: "確認")
                
            }
        }
    }
    
    private func deleteSharePlant(sharePlants: [String]) {
        userManager.deleteSharePlant(sharePlants: sharePlants) { isSuccess in
            if isSuccess {
                self.updateSharePlants(withAnimation: true)
            }
        }
    }
    
    private func editPlantAction(indexPath: IndexPath) {
        
        guard let plants = plants else { return }
        
        let plant = plants[indexPath.row]
        
        performSegue(
            withIdentifier: SegueIdentifier.editPlant,
            sender: plant)
        
    }
    
    private func deathPlantAction(indexPath: IndexPath) {
        
        guard let plants = plants else { return }
        
        let plant = plants[indexPath.row]
        
        performSegue(withIdentifier: SegueIdentifier.deathPlant, sender: plant)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if Auth.auth().currentUser == nil {
            
            showLoginAlert()
            
            return
        }
        
        switch segue.identifier {
            
        case SegueIdentifier.showPlantDetail:
            
            guard let destinationVC = segue.destination as? PlantDetailViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.plant = plant
            
        case SegueIdentifier.createPlant:
            
            guard let destinationVC = segue.destination as? NewPlantPageViewController else { return }
            
            destinationVC.pageMode = .create
            
            destinationVC.parentVC = self
            
        case SegueIdentifier.editPlant:
            
            guard let destinationVC = segue.destination as? NewPlantPageViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.pageMode = .edit(editedPlant: plant)
            
            destinationVC.parentVC = self
            
        case SegueIdentifier.deathPlant:
            
            guard let destinationVC = segue.destination as? DeathPlantViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.plant = plant

        default:
            
            break
        }
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
        guard let plants = plants else { return }
        
        let group = DispatchGroup()
        
        plants.forEach({ plant in
            group.enter()
            firebaseManager.updateWater(plant: plant) { _ in
                group.leave()
            }
        })
        
        group.notify(queue: .main) {
            
            let dropAnimation = self.loadAnimation(name: "61313-waterDrop", loopMode: .playOnce)
            
            dropAnimation.contentMode = .scaleToFill
            
            dropAnimation.frame = self.view.frame
            
            self.view.addSubview(dropAnimation)
            
            dropAnimation.play { _ in
                dropAnimation.removeFromSuperview()
            }
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        
        guard let dropView = sender.view,
              let cells = plantCollectionView.visibleCells as? [PlantCollectionViewCell]
        else { return }
        
        UIView.animate(withDuration: 0.1) {() -> Void in
            dropView.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
        
        let translation = sender.translation(in: view)
        dropView.center.x += translation.x
        dropView.center.y += translation.y
        sender.setTranslation(.zero, in: view)
        
        let selectedPoint = dropView.convert(CGPoint.zero, to: self.plantCollectionView)
        
        if let indexPath = plantCollectionView.indexPathForItem(at: selectedPoint) {
            
            if let selectedCell = plantCollectionView.cellForItem(at: indexPath) as? PlantCollectionViewCell {
                
                cells.forEach { $0.isPanOnCell = ($0 == selectedCell) }
            }
            
        } else {
            
            cells.forEach { $0.isPanOnCell = false }
        }
        
        if sender.state == .ended {
            
            if let cells = plantCollectionView.visibleCells as? [PlantCollectionViewCell] {
                cells.forEach { $0.isPanOnCell = false }
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
               let plants = self.plants,
               let cell = self.plantCollectionView.cellForItem(at: indexPath),
               let plantCell = cell as? PlantCollectionViewCell {
                
//                let plantName = plants[indexPath.row].name
                
                firebaseManager.updateWater(plant: plants[indexPath.row]) { [weak self] isSuccess in
                    
                    guard let self = self else { return }
                    
                    if isSuccess {
                        
                        dropView.isUserInteractionEnabled = true
                        
                        let dropAnimation = self.loadAnimation(name: "61313-waterDrop", loopMode: .playOnce)
                        
                        dropAnimation.frame = self.plantCollectionView.convert(plantCell.frame, to: self.view)
                        
                        dropAnimation.contentMode = .scaleToFill
                        
                        self.view.addSubview(dropAnimation)
                        
                        dropAnimation.play { _ in
                            dropAnimation.removeFromSuperview()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == buttonCollectionView {
            
            return HomePageButton.allCases.count
            
        } else {
            
            if isSearching {
                
                guard let searchPlants = self.searchedPlants else { return 0 }
                
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
            
            if isSearching {
                
                guard let searchPlants = self.searchedPlants
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
        
        let columnCount: CGFloat = 3
        
        let plantWidth = floor((plantCollectionView.bounds.width - itemSpace * (columnCount - 1)) / columnCount )
        
        let buttonWidth = floor((buttonCollectionView.bounds.width - 35 * (columnCount - 1)) / columnCount )

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
        
            performSegue(
                withIdentifier: SegueIdentifier.showPlantDetail,
                sender: plant)
            
        } else if collectionView == buttonCollectionView {
            
            let buttonType = HomePageButton.allCases[indexPath.row]
            
            switch buttonType {
                
            case .myPlant:
                
                if selectionType == .myPlant { break }
                
                updateMyPlants(withAnimation: true)
                
                self.selectionType = .myPlant
                
            case .myFavorite:
                
                if selectionType == .myFavorite { break }
                
                isSearching = false
                
                updateMyFavoritePlants(withAnimation: true)
                
                selectionType = .myFavorite
                
            case .sharePlants:
                
                if selectionType == .sharePlants { break }
                
                selectionType = .sharePlants
                
                isSearching = false
                
                updateSharePlants(withAnimation: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard collectionView == plantCollectionView else { return nil }
        
        if selectionType == .sharePlants {
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil) { _ in
                
                let deleteAction = UIAction(title: "取消收藏",
                                            image: UIImage(systemName: "trash"),
                                            attributes: .destructive) { _ in
                    if let currentUser = self.userManager.currentUser,
                       var sharePlants = currentUser.sharePlants {
                        
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
        
        searchedPlants = plants.filter { plant -> Bool in
            
            return plant.name.contains(searchText)
        }
        
        isSearching = (searchText != "")
        
        reloadCollectionViewInSection(self.plantCollectionView)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        isSearching = false
        
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
    }
}
