//
//  ToolStockViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/10.
//

import UIKit

class ToolStockViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerCellWithNib(identifier: String(describing: ToolStockTableViewCell.self),
                                          bundle: nil)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var toolList: [Tool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func reloadData() {
        FirebaseManager.shared.fetchTool { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let tools):
                self.toolList = tools
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func addNewTool(_ sender: UIButton) {
     
        guard let addPageVC = storyboard?.instantiateViewController(
            withIdentifier: String(describing: AddToolStockViewController.self))
                as? AddToolStockViewController
        else { return }
        
        addPageVC.modalTransitionStyle = .crossDissolve
        addPageVC.modalPresentationStyle = .overCurrentContext
        addPageVC.parentVC = self
        navigationController?.present(addPageVC, animated: true, completion: nil)
    }
}

extension ToolStockViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toolList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ToolStockTableViewCell.self),
            for: indexPath)
        
        guard let toolCell = cell as? ToolStockTableViewCell else { return cell }
        
        toolCell.layoutCell(tool: toolList[indexPath.row])
        
        return toolCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let addPageVC = storyboard?.instantiateViewController(
            withIdentifier: String(describing: AddToolStockViewController.self))
                as? AddToolStockViewController else { return }
        
        addPageVC.modalTransitionStyle = .crossDissolve
        addPageVC.modalPresentationStyle = .overCurrentContext
        addPageVC.parentVC = self
        addPageVC.tool = toolList[indexPath.row]
        navigationController?.present(addPageVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let tool = toolList[indexPath.row]
            FirebaseManager.shared.deleteData(.tool, dataID: tool.id) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.toolList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
