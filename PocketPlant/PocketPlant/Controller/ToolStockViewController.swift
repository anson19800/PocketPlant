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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ToolStockViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ToolStockTableViewCell.self),
            for: indexPath)
        
        guard let toolCell = cell as? ToolStockTableViewCell else { return cell }
        
        return toolCell
    }
}
