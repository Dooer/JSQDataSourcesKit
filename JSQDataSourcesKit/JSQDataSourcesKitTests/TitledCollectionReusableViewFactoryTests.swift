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


class TitledCollectionReusableViewFactoryTests: XCTestCase {

    private let fakeCellReuseId = "fakeCellId"
    private let fakeSupplementaryViewReuseId = "fakeSupplementaryId"

    private let fakeCollectionView = FakeCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 600), collectionViewLayout: FakeFlowLayout())
    private let dequeueCellExpectationName = "collectionview_dequeue_cell_expectation"
    private let dequeueSupplementaryViewExpectationName = "collectionview_dequeue_supplementaryview_expectation"

    override func setUp() {
        super.setUp()

        fakeCollectionView.registerClass(FakeCollectionCell.self,
            forCellWithReuseIdentifier: fakeCellReuseId)

        fakeCollectionView.registerNib(TitledCollectionReusableView.nib,
            forSupplementaryViewOfKind: FakeSupplementaryViewKind,
            withReuseIdentifier: TitledCollectionReusableView.identifier)
    }

    func test_ThatCollectionViewDataSource_ReturnsExpectedData_TitledCollectionReusableViewFactory() {

        // GIVEN: some collection view sections
        let section0 = CollectionViewSection(items: FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel())
        let section1 = CollectionViewSection(items: FakeViewModel(), FakeViewModel())
        let section2 = CollectionViewSection(items: FakeViewModel(), FakeViewModel(), FakeViewModel(), FakeViewModel())
        let allSections = [section0, section1, section2]

        var cellFactoryExpectation = expectationWithDescription("cell_factory")

        // GIVEN: a cell factory
        let cellFactory = CollectionViewCellFactory(reuseIdentifier: fakeCellReuseId)
            { (cell: FakeCollectionCell, model: FakeViewModel, view: UICollectionView, indexPath: NSIndexPath) -> FakeCollectionCell in
            cellFactoryExpectation.fulfill()
            return cell
        }

        var titledViewDataConfigExpectation = expectationWithDescription("titledViewDataConfigExpectation")
        var titledViewStyleConfigExpectation = expectationWithDescription("titledViewStyleConfigExpectation")

        let supplementaryViewFactory = TitledCollectionReusableViewFactory(dataConfigurator:
            { (view, item: FakeViewModel, kind, collectionView, indexPath) -> TitledCollectionReusableView in
                XCTAssertEqual(view.reuseIdentifier!, TitledCollectionReusableView.identifier, "Dequeued supplementary view should have expected identifier")
                XCTAssertEqual(kind, FakeSupplementaryViewKind, "View kind should have expected kind")
                XCTAssertEqual(item, allSections[indexPath.section][indexPath.item], "Model object should equal expected value")
                XCTAssertEqual(collectionView, self.fakeCollectionView, "CollectionView should equal the collectionView for the data source")

                titledViewDataConfigExpectation.fulfill()
                return view
            },
            styleConfigurator: { (view) in
                titledViewStyleConfigExpectation.fulfill()
        })

        // GIVEN: a data source provider
        let dataSourceProvider = CollectionViewDataSourceProvider(
            sections: allSections,
            cellFactory: cellFactory,
            supplementaryViewFactory: supplementaryViewFactory,
            collectionView: fakeCollectionView)

        let dataSource = dataSourceProvider.dataSource

        // WHEN: we call the collection view data source methods
        let numSections = dataSource.numberOfSectionsInCollectionView?(fakeCollectionView)

        // THEN: we receive the expected return values
        XCTAssertNotNil(numSections, "Number of sections should not be nil")
        XCTAssertEqual(numSections!, dataSourceProvider.sections.count, "Data source should return expected number of sections")

        for sectionIndex in 0..<dataSourceProvider.sections.count {
            for rowIndex in 0..<dataSourceProvider[sectionIndex].items.count {

                let expectationName = "\(#function)_\(sectionIndex)_\(rowIndex)"
                fakeCollectionView.dequeueCellExpectation = expectationWithDescription(dequeueCellExpectationName + expectationName)
                fakeCollectionView.dequeueSupplementaryViewExpectation = expectationWithDescription(dequeueSupplementaryViewExpectationName + expectationName)

                let indexPath = NSIndexPath(forItem: rowIndex, inSection: sectionIndex)

                // WHEN: we call the collection view data source methods
                let numRows = dataSource.collectionView(fakeCollectionView, numberOfItemsInSection: sectionIndex)
                let cell = dataSource.collectionView(fakeCollectionView, cellForItemAtIndexPath: indexPath)
                let supplementaryView = dataSource.collectionView?(fakeCollectionView, viewForSupplementaryElementOfKind: FakeSupplementaryViewKind, atIndexPath: indexPath)

                // THEN: we receive the expected return values for cells
                XCTAssertEqual(numRows, dataSourceProvider[sectionIndex].count, "Data source should return expected number of rows for section \(sectionIndex)")
                XCTAssertEqual(cell.reuseIdentifier!, fakeCellReuseId, "Data source should return cells with the expected identifier")

                // THEN: we receive the expected return values for supplementary views
                XCTAssertNotNil(supplementaryView, "Supplementary view should not be nil")
                XCTAssertEqual(supplementaryView!.reuseIdentifier!, TitledCollectionReusableView.identifier,
                    "Data source should return supplementary views with the expected identifier")

                // THEN: the collectionView calls `dequeueReusableCellWithReuseIdentifier`
                // THEN: the cell factory calls its `ConfigurationHandler`

                // THEN: the collectionView calls `dequeueReusableSupplementaryViewOfKind`
                // THEN: the supplementary view factory calls its `dataConfigurator`
                // THEN: the supplementary view factory calls its `styleConfigurator`
                waitForExpectationsWithTimeout(DefaultTimeout, handler: { (error) -> Void in
                    XCTAssertNil(error, "Expections should not error")
                })
                
                // reset expectation names for next loop, ignore last item
                if !(sectionIndex == dataSourceProvider.sections.count - 1 && rowIndex == dataSourceProvider[sectionIndex].count - 1) {
                    cellFactoryExpectation = expectationWithDescription("cell_factory_" + expectationName)
                    titledViewDataConfigExpectation = expectationWithDescription("titledViewDataConfigExpectation_" + expectationName)
                    titledViewStyleConfigExpectation = expectationWithDescription("titledViewStyleConfigExpectation_")
                }
            }
        }
    }
    
}
