//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://jessesquires.com/JSQDataSourcesKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQDataSourcesKit
//
//
//  License
//  Copyright © 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

import JSQDataSourcesKit


class TableViewController: UITableViewController {

    typealias Section = TableViewSection<CellViewModel>
    typealias CellFactory = TableViewCellFactory<UITableViewCell, CellViewModel>
    var dataSourceProvider: TableViewDataSourceProvider<Section, CellFactory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editing = true

        // 1. create view models
        let section0 = TableViewSection(items: CellViewModel(), CellViewModel(), CellViewModel(), headerTitle: "First")
        let section1 = TableViewSection(items: CellViewModel(), CellViewModel(), CellViewModel(), CellViewModel(), headerTitle: "Second", footerTitle: "Only 2nd has a footer")
        let section2 = TableViewSection(items: CellViewModel(), CellViewModel(), headerTitle: "Third")
        let allSections = [section0, section1, section2]

        // 2. create cell factory
        let factory = TableViewCellFactory(reuseIdentifier: CellId) { (cell: UITableViewCell, model: CellViewModel, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell in
            cell.textLabel?.text = model.text
            cell.detailTextLabel?.text = "\(indexPath.section), \(indexPath.row)"
            return cell
        }

        // 3. create data source provider
        dataSourceProvider = TableViewDataSourceProvider(
            sections: allSections,
            cellFactory: factory,
            userMovedHandler: { tableView, cell, model, fromIndexPath, toIndexPath in
                cell.detailTextLabel?.text = "\(toIndexPath.section), \(toIndexPath.row)"
            },
            tableView: tableView
        )
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}
