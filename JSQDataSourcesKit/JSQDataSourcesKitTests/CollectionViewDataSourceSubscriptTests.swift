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

import Foundation
import UIKit
import XCTest

import JSQDataSourcesKit


class CollectionViewDataSourceSubscriptTests: XCTestCase {

    func test_ThatCollectionViewDataSourceProvider_ReturnsExpectedDataFrom_IntSubscript() {

        // GIVEN: some collection view sections
        let section0 = CollectionViewSection(items: FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel())
        let section1 = CollectionViewSection(items: FakeViewModel(), FakeViewModel())
        let section2 = CollectionViewSection(items: FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel())
        let allSections = [section0, section1, section2]

        // GIVEN: a cell factory
        let factory = CollectionViewCellFactory(reuseIdentifier: "cellId") { (cell: FakeCollectionCell, model: FakeViewModel, view: UICollectionView, index: IndexPath) -> FakeCollectionCell in
            return cell
        }

        // GIVEN: a data source provider
        let dataSourceProvider: Provider = CollectionViewDataSourceProvider(sections: allSections, cellFactory: factory)

        // WHEN: we ask for a section at a specific index
        let section = dataSourceProvider[1]

        // THEN: we receive the expected section
        XCTAssertEqual(section.items, section1.items, "Section returned from subscript should equal expected section")
    }

    func test_ThatCollectionViewDataSourceProvider_SetsExpectedDataAt_IntSubscript() {

        // GIVEN: some collection view sections
        let section0 = CollectionViewSection(items: FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel())
        let section1 = CollectionViewSection(items: FakeViewModel(), FakeViewModel())
        let section2 = CollectionViewSection(items: FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel())
        let allSections = [section0, section1, section2]

        // GIVEN: a cell factory
        let factory = CollectionViewCellFactory(reuseIdentifier: "cellId") { (cell: FakeCollectionCell, model: FakeViewModel, view: UICollectionView, index: IndexPath) -> FakeCollectionCell in
            return cell
        }

        // GIVEN: a data source provider
        let dataSourceProvider: Provider = CollectionViewDataSourceProvider(sections: allSections, cellFactory: factory)
        let count = dataSourceProvider.sections.count

        // WHEN: we set a section at a specific index
        let index = 0
        let expectedSection = CollectionViewSection(items: FakeViewModel(), FakeViewModel())
        dataSourceProvider[index] = expectedSection

        // THEN: the section at the specified index is replaced with the new section
        XCTAssertEqual(dataSourceProvider[index].items, expectedSection.items, "Section set at subscript should equal expected section")
        XCTAssertEqual(count, dataSourceProvider.sections.count, "Number of sections should remain unchanged")
    }

    func test_ThatCollectionViewDataSourceProvider_ReturnsExpectedDataFrom_IndexPathSubscript() {

        // GIVEN: some collection view sections
        let section0 = CollectionViewSection(items: FakeViewModel(), FakeViewModel(), FakeViewModel())
        let section1 = CollectionViewSection(items: FakeViewModel(), FakeViewModel())
        let allSections = [section0, section1]

        // GIVEN: a cell factory
        let factory = CollectionViewCellFactory(reuseIdentifier: "cellId") { (cell: FakeCollectionCell, model: FakeViewModel, view: UICollectionView, index: IndexPath) -> FakeCollectionCell in
            return cell
        }

        // GIVEN: a data source provider
        let dataSourceProvider: Provider = CollectionViewDataSourceProvider(sections: allSections, cellFactory: factory)

        // WHEN: we ask for an item at a specific index path
        let item1 = dataSourceProvider[IndexPath(item: 2, section: 0)]
        let item2 = dataSourceProvider[IndexPath(item: 0, section: 1)]

        // THEN: we receive the expected item
        XCTAssertEqual(item1, section0[2], "Item returned from subscript should equal expected item")
        XCTAssertEqual(item2, section1[0], "Item returned from subscript should equal expected item")
    }

    func test_ThatCollectionViewDataSourceProvider_SetsExpectedDataAt_IndexPathSubscript() {

        // GIVEN: some collection view sections
        let section0 = CollectionViewSection(items: FakeViewModel(), FakeViewModel(), FakeViewModel())
        let section1 = CollectionViewSection(items: FakeViewModel(), FakeViewModel())
        let allSections = [section0, section1]

        // GIVEN: a cell factory
        let factory = CollectionViewCellFactory(reuseIdentifier: "cellId") { (cell: FakeCollectionCell, model: FakeViewModel, view: UICollectionView, index: IndexPath) -> FakeCollectionCell in
            return cell
        }

        // GIVEN: a data source provider
        let dataSourceProvider: Provider = CollectionViewDataSourceProvider(sections: allSections, cellFactory: factory)

        // WHEN: we set an item at a specific index path
        let indexPath = IndexPath(item: 2, section: 0)
        let expectedItem = FakeViewModel()

        dataSourceProvider[indexPath] = expectedItem

        // THEN: the item at the specified index path is replaced with the new item
        XCTAssertEqual(dataSourceProvider[indexPath], expectedItem, "Item set at subscript should equal expected item")
        XCTAssertEqual(2, dataSourceProvider.sections.count, "Number of sections should remain unchanged")
        XCTAssertEqual(3, section0.count, "Number of items in section should remain unchanged")
    }

}
