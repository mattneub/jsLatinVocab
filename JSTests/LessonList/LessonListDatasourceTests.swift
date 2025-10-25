@testable import JSLatin
import Testing
import UIKit
import WaitWhile

struct LessonListDatasourceTests {
    let layout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    let subject: LessonListDatasource!
    let processor = MockReceiver<LessonListAction>()

    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        subject = LessonListDatasource(collectionView: collectionView, processor: processor)
    }

    @Test("initialize: creates and configures data source, configures flow layout")
    func initialize() async throws {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let subject = LessonListDatasource(collectionView: collectionView, processor: nil)
        let datasource = try #require(subject.datasource)
        #expect(collectionView.dataSource === datasource)
        #expect(collectionView.delegate === subject)
        #expect(layout.sectionInset == UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        #expect(layout.headerReferenceSize == CGSize(width: 0, height: 40))
        #expect(layout.itemSize == CGSize(width: 70, height: 45))
        // initialize also registers cell and header types, but we will prove that by examining cells
    }

    @Test("present: constructs datasource data")
    func present() async throws {
        let string0 = "latin\tenglish\t10\tc\tpart"
        let string1 = "latin\tenglish\t2\ta\tpart"
        let string2 = "latin\tenglish\t1\tb\tpart"
        let string3 = "latin\tenglish\t1\tb another word\tpart"
        let string4 = "latin\tenglish\t1\tc\tpart"
        let terms = [string0, string1, string2, string3, string4].map { Term(tabbedString: $0, index: 0)}
        await subject.present(.init(terms: terms))
        let snapshot = subject.datasource.snapshot()
        #expect(snapshot.sectionIdentifiers == ["1", "2", "10"]) // numeric order
        #expect(snapshot.itemIdentifiers(inSection: "1") == ["1b", "1c"]) // sections clumped by first word
        #expect(snapshot.itemIdentifiers(inSection: "2") == ["2a"])
        #expect(snapshot.itemIdentifiers(inSection: "10") == ["10c"])
    }

    @Test("cells are correctly configured")
    func cells() async throws {
        makeWindow(view: collectionView)
        let string1 = "latin\tenglish\t2\ta\tpart"
        let string2 = "latin\tenglish\t1\tb\tpart"
        let string3 = "latin\tenglish\t1\tb another word\tpart"
        let string4 = "latin\tenglish\t1\tc\tpart"
        let terms = [string1, string2, string3, string4].map { Term(tabbedString: $0, index: 0)}
        await subject.present(.init(terms: terms))
        let cell = try #require(collectionView.cellForItem(at: .init(item: 0, section: 0)) as? UICollectionViewListCell)
        let content = try #require(cell.contentConfiguration as? UIListContentConfiguration)
        #expect(content.text == "1b")
        #expect(content.textProperties.font == UIFont(name: "Georgia-Bold", size: 15)!)
        #expect(content.textProperties.alignment == .center)
        #expect(content.directionalLayoutMargins == .init(top: 0, leading: 0, bottom: 0, trailing: 0))
        let background = try #require(cell.backgroundConfiguration)
        #expect(background.strokeColor == .brown)
        #expect(background.strokeWidth == 5)
        #expect(background.cornerRadius == 5)
        #expect(background.resolvedBackgroundColor(for: .clear) == .myPaler)
        collectionView.selectItem(at: .init(item: 0, section: 0), animated: false, scrollPosition: [])
        #expect(background.resolvedBackgroundColor(for: .clear) == .blue.withAlphaComponent(0.8))
    }

    @Test("headers are correctly configured")
    func headers() async throws {
        makeWindow(view: collectionView)
        let string1 = "latin\tenglish\t2\ta\tpart"
        let string2 = "latin\tenglish\t1\tb\tpart"
        let string3 = "latin\tenglish\t1\tb another word\tpart"
        let string4 = "latin\tenglish\t1\tc\tpart"
        let terms = [string1, string2, string3, string4].map { Term(tabbedString: $0, index: 0)}
        await subject.present(.init(terms: terms))
        let header = try #require(collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: .init(item: 0, section: 1)
        ) as? UICollectionViewCell)
        let configuration = try #require(header.contentConfiguration as? LessonListHeaderContentConfiguration)
        #expect(configuration.text == "2")
        #expect(header.backgroundColor == .black)
    }

    @Test("didSelectItem: deselects item, sends .selectedLessonSection")
    func didSelectItem() async throws {
        makeWindow(view: collectionView)
        let string1 = "zebra\tenglish zebra\t2\ta\tpart"
        let string2 = "yak\tenglish yak\t1\tb\tpart"
        let string3 = "aardvark\tenglish aardvark\t1\tc\tpart"
        let string4 = "aardvark\tenglish aardvark\t1\tb\tpart"
        let terms = [string1, string2, string3, string4].enumerated().map { Term(tabbedString: $0.1, index: $0.0)}
        await subject.present(.init(terms: terms))
        collectionView.selectItem(at: .init(row: 0, section: 0), animated: false, scrollPosition: [])
        #expect(collectionView.indexPathsForSelectedItems?.first == IndexPath(item: 0, section: 0))
        // that was prep, this is the test
        subject.collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        await #while(collectionView.indexPathsForSelectedItems?.first == IndexPath(item: 0, section: 0))
        #expect(collectionView.indexPathsForSelectedItems?.first == nil)
        #expect(processor.thingsReceived.first == .selectedLessonSection("1b"))
    }

    @Test("sizeForItem: if section 0, width is 150; else, incoming size")
    func sizeForItem() {
        var result = subject.collectionView(collectionView, layout: layout, sizeForItemAt: IndexPath(item: 0, section: 0))
        #expect(result.width == 150)
        result = subject.collectionView(collectionView, layout: layout, sizeForItemAt: IndexPath(item: 0, section: 1))
        #expect(result.width == 70)
    }

    @Test("sizeForHeader: if section 0, zero; else, incoming height")
    func sizeForHeader() {
        var result = subject.collectionView(collectionView, layout: layout, referenceSizeForHeaderInSection: 0)
        #expect(result.height == 0)
        result = subject.collectionView(collectionView, layout: layout, referenceSizeForHeaderInSection: 1)
        #expect(result.height == 40)
    }
}
