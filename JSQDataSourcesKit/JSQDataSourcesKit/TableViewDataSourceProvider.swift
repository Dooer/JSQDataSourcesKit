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

import CoreData
import Foundation
import UIKit


/**
 A `TableViewDataSourceProvider` is responsible for providing a data source object for a table view.

 - warning: **Clients are responsbile for the following:**
    - Registering cells with the table view
    - Adding, removing, or reloading cells and sections as the provider's `sections` are modified.
 */
public final class TableViewDataSourceProvider <
    SectionInfo: TableViewSectionInfo,
    CellFactory: TableViewCellFactoryType
    where CellFactory.Item == SectionInfo.Item>: CustomStringConvertible {

    // MARK: Typealiases

    /// The type of elements for the data source provider.
    public typealias Item = SectionInfo.Item

    /// A function for reacting to a user move of a row
    public typealias UserMovedHandler = (UITableView, CellFactory.Cell, Item,  NSIndexPath, NSIndexPath) -> Void

    // MARK: Properties

    /// The sections in the table view
    public var sections: [SectionInfo]

    /// Returns the cell factory for this data source provider.
    public let cellFactory: CellFactory

    /// Returns the object that provides the data for the table view.
    public var dataSource: UITableViewDataSource { return bridgedDataSource }


    // MARK: Initialization

    /**
    Constructs a new data source provider for a table view.

    - parameter sections:         The sections to display in the table view.
    - parameter cellFactory:      The cell factory from which the table view data source will dequeue cells.
    - parameter userMovedHandler: Enables drag 'n' drop reordering when set. Called whenever a user moves a row to a new index path.
    - parameter tableView:        The table view whose data source will be provided by this provider.

    - returns: A new `TableViewDataSourceProvider` instance.
    */
    public init(
        sections: [SectionInfo],
        cellFactory: CellFactory,
        userMovedHandler: UserMovedHandler? = nil,
        tableView: UITableView? = nil) {
            self.sections = sections
            self.cellFactory = cellFactory
            self.userMovedHandler = userMovedHandler
            tableView?.dataSource = dataSource
    }


    // MARK: Subscripts

    /**
    - parameter index: The index of the section to return.
    - returns: The section at `index`.
    */
    public subscript (index: Int) -> SectionInfo {
        get {
            return sections[index]
        }
        set {
            sections[index] = newValue
        }
    }

    /**
     - parameter indexPath: The index path of the item to return.
     - returns: The item at `indexPath`.
     */
    public subscript (indexPath: NSIndexPath) -> Item {
        get {
            return sections[indexPath.section].items[indexPath.row]
        }
        set {
            sections[indexPath.section].items[indexPath.row] = newValue
        }
    }


    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            return "<\(TableViewDataSourceProvider.self): sections=\(sections)>"
        }
    }


    // MARK: Private

    private var userMovedHandler: UserMovedHandler?
    
    private lazy var bridgedDataSource: BridgedTableViewDataSource = BridgedTableViewDataSource(
        numberOfSections: { [unowned self] () -> Int in
            self.sections.count
        },
        numberOfRowsInSection: { [unowned self] (section) -> Int in
            self.sections[section].items.count
        },
        cellForRowAtIndexPath: { [unowned self] (tableView, indexPath) -> UITableViewCell in
            let item = self.sections[indexPath.section].items[indexPath.row]
            let cell = self.cellFactory.cellForItem(item, inTableView: tableView, atIndexPath: indexPath)
            return self.cellFactory.configureCell(cell, forItem: item, inTableView: tableView, atIndexPath: indexPath)
        },
        titleForHeaderInSection: { [unowned self] (section) -> String? in
            self.sections[section].headerTitle
        },
        titleForFooterInSection: { [unowned self] (section) -> String? in
            self.sections[section].footerTitle
        },
        moveHandler: self.userMovedHandler.flatMap(self.tableViewMoveHandlerForUserMovedHandler))
    
    private func tableViewMoveHandlerForUserMovedHandler(userMovedHandler: UserMovedHandler) -> BridgedTableViewDataSource.MoveHandler {
        
        return { [unowned self] tableView, sourceIndexPath, destinationIndexPath in
            let item = self.sections[sourceIndexPath.section].items.removeAtIndex(sourceIndexPath.item)
            self.sections[destinationIndexPath.section].items.insert(item, atIndex: destinationIndexPath.item)
            
            // Dispatch to main queue so UITableView can update its internal state
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if let cell = tableView.cellForRowAtIndexPath(destinationIndexPath) as? CellFactory.Cell {
                    userMovedHandler(tableView, cell, item, sourceIndexPath, destinationIndexPath)
                }
            }
        }
    }
}

/**
 A `TableViewFetchedResultsDataSourceProvider` is responsible for providing a data source object for a table view
 that is backed by an `NSFetchedResultsController` instance.

 - warning: The `CellFactory.Item` type should correspond to the type of objects that the `NSFetchedResultsController` fetches.
 - note: Clients are responsbile for registering cells with the table view.
 */
public final class TableViewFetchedResultsDataSourceProvider <CellFactory: TableViewCellFactoryType>: CustomStringConvertible {

    // MARK: Typealiases

    /// The type of elements for the data source provider.
    public typealias Item = CellFactory.Item


    // MARK: Properties

    /// Returns the fetched results controller that provides the data for the table view data source.
    public let fetchedResultsController: NSFetchedResultsController

    /// Returns the cell factory for this data source provider.
    public let cellFactory: CellFactory

    /// Returns the object that provides the data for the table view.
    public var dataSource: UITableViewDataSource { return bridgedDataSource }


    // MARK: Initialization

    /**
    Constructs a new data source provider for the table view.

    - parameter fetchedResultsController: The fetched results controller that provides the data for the table view.
    - parameter cellFactory:              The cell factory from which the table view data source will dequeue cells.
    - parameter tableView:                The table view whose data source will be provided by this provider.

    - returns: A new `TableViewFetchedResultsDataSourceProvider` instance.
    */
    public init(fetchedResultsController: NSFetchedResultsController, cellFactory: CellFactory, tableView: UITableView? = nil) {
        assert(fetchedResultsController: fetchedResultsController,
            fetchesObjectsOfClass: Item.self as! AnyClass)

        self.fetchedResultsController = fetchedResultsController
        self.cellFactory = cellFactory
        tableView?.dataSource = dataSource
    }


    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            return "<\(TableViewFetchedResultsDataSourceProvider.self): fetchedResultsController=\(fetchedResultsController)>"
        }
    }


    // MARK: Private

    private lazy var bridgedDataSource: BridgedTableViewDataSource = BridgedTableViewDataSource(
        numberOfSections: { [unowned self] () -> Int in
            self.fetchedResultsController.sections?.count ?? 0
        },
        numberOfRowsInSection: { [unowned self] (section) -> Int in
            return (self.fetchedResultsController.sections?[section])?.numberOfObjects ?? 0
        },
        cellForRowAtIndexPath: { [unowned self] (tableView, indexPath) -> UITableViewCell in
            let item = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Item
            let cell = self.cellFactory.cellForItem(item, inTableView: tableView, atIndexPath: indexPath)
            return self.cellFactory.configureCell(cell, forItem: item, inTableView: tableView, atIndexPath: indexPath)
        },
        titleForHeaderInSection: { [unowned self] (section) -> String? in
            return (self.fetchedResultsController.sections?[section])?.name
        },
        titleForFooterInSection: { (section) -> String? in
            return nil
    })
}


/*
Avoid making DataSourceProvider inherit from NSObject.
Keep classes pure Swift.
Keep responsibilies focused.
*/
@objc private final class BridgedTableViewDataSource: NSObject, UITableViewDataSource {

    typealias NumberOfSectionsHandler = () -> Int
    typealias NumberOfRowsInSectionHandler = (Int) -> Int
    typealias CellForRowAtIndexPathHandler = (UITableView, NSIndexPath) -> UITableViewCell
    typealias TitleForHeaderInSectionHandler = (Int) -> String?
    typealias TitleForFooterInSectionHandler = (Int) -> String?
    typealias MoveHandler = (UITableView, NSIndexPath, NSIndexPath) -> Void

    let numberOfSections: NumberOfSectionsHandler
    let numberOfRowsInSection: NumberOfRowsInSectionHandler
    let cellForRowAtIndexPath: CellForRowAtIndexPathHandler
    let titleForHeaderInSection: TitleForHeaderInSectionHandler
    let titleForFooterInSection: TitleForFooterInSectionHandler
    let moveHandler: MoveHandler?

    init(numberOfSections: NumberOfSectionsHandler,
        numberOfRowsInSection: NumberOfRowsInSectionHandler,
        cellForRowAtIndexPath: CellForRowAtIndexPathHandler,
        titleForHeaderInSection: TitleForHeaderInSectionHandler,
        titleForFooterInSection: TitleForFooterInSectionHandler,
        moveHandler: MoveHandler? = nil) {

            self.numberOfSections = numberOfSections
            self.numberOfRowsInSection = numberOfRowsInSection
            self.cellForRowAtIndexPath = cellForRowAtIndexPath
            self.titleForHeaderInSection = titleForHeaderInSection
            self.titleForFooterInSection = titleForFooterInSection
            self.moveHandler = moveHandler
    }

    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections()
    }

    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection(section)
    }

    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellForRowAtIndexPath(tableView, indexPath)
    }

    @objc func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection(section)
    }
    
    @objc func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection(section)
    }
    
    @objc func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return moveHandler != nil
    }
    
    @objc func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        moveHandler?(tableView, sourceIndexPath, destinationIndexPath)
    }
}
