@testable import JSLatin
import Testing
import UIKit

struct AllTermsDatasourceTests {
    let subject: AllTermsDatasource!
    let processor = MockReceiver<AllTermsAction>()
    let tableView = UITableView()

    init() {
        subject = AllTermsDatasource(tableView: tableView, processor: processor)
    }

    @Test("Initialization: creates and configures the data source, configures the table view")
    func initialize() throws {
        let datasource = try #require(subject.datasource)
        #expect(tableView.dataSource === datasource)
        #expect(tableView.delegate === subject)
        #expect(tableView.rowHeight == 50)
        #expect(tableView.sectionHeaderHeight == 26)
        #expect(tableView.sectionHeaderTopPadding == 0)
        #expect(tableView.topEdgeEffect.style == .hard)
    }

    @Test("present: configures the contents of the datasource")
    func present() async throws {
        let string1 = "zebra\tenglish zebra\t2\ta\tpart"
        let string2 = "yak\tenglish yak\t1\tb\tpart"
        let string3 = "aardvark\tenglish aardvark\t1\tc\tpart"
        let string4 = "aardvark\tenglish aardvark\t1\tb\tpart"
        let terms = [string1, string2, string3, string4].enumerated().map { Term(tabbedString: $0.1, index: $0.0)}
        await subject.present(.init(terms: terms))
        let snapshot = subject.datasource.snapshot()
        #expect(snapshot.sectionIdentifiers == ["A", "Y", "Z"])
        #expect(snapshot.itemIdentifiers(inSection: "A") == [3, 2])
        #expect(snapshot.itemIdentifiers(inSection: "Y") == [1])
        #expect(snapshot.itemIdentifiers(inSection: "Z") == [0])
    }

    @Test("cells are correctly constructed")
    func cells() async throws {
        makeWindow(view: tableView)
        let string1 = "zebra\tenglish zebra\t2\ta\tpart"
        let string2 = "yak\tenglish yak\t1\tb\tpart"
        let string3 = "aardvark\tenglish aardvark\t1\tc\tpart"
        let string4 = "aardvark\tenglish aardvark\t1\tb\tpart"
        let terms = [string1, string2, string3, string4].enumerated().map { Term(tabbedString: $0.1, index: $0.0)}
        await subject.present(.init(terms: terms))
        let cell = try #require(tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
        let content = try #require(cell.contentConfiguration as? UIListContentConfiguration)
        #expect(content.text == "aardvark")
        #expect(content.textProperties.font == UIFont(name:"Times New Roman", size: 18)!)
        #expect(content.textProperties.color == .black)
        #expect(content.secondaryText == "english aardvark — 1b") // also proves sort order is correct
        #expect(content.secondaryTextProperties.font == UIFont.systemFont(ofSize: 12))
        #expect(content.secondaryTextProperties.lineBreakMode == .byTruncatingMiddle)
        #expect(content.secondaryTextProperties.color == .black)
        #expect(content.directionalLayoutMargins == .init(top: 2, leading: 0, bottom: 6, trailing: 0))
        let background = try #require(cell.backgroundConfiguration)
        #expect(background.resolvedBackgroundColor(for: .clear) == .myPaler)
        tableView.selectRow(at: .init(row: 0, section: 0), animated: false, scrollPosition: .none)
        #expect(background.resolvedBackgroundColor(for: .clear) == .blue.withAlphaComponent(0.8))
    }

    @Test("headers are correctly constructed")
    func headers() async throws {
        makeWindow(view: tableView)
        let string1 = "zebra\tenglish zebra\t2\ta\tpart"
        let string2 = "yak\tenglish yak\t1\tb\tpart"
        let string3 = "aardvark\tenglish aardvark\t1\tc\tpart"
        let string4 = "aardvark\tenglish aardvark\t1\tb\tpart"
        let terms = [string1, string2, string3, string4].enumerated().map { Term(tabbedString: $0.1, index: $0.0)}
        await subject.present(.init(terms: terms))
        let header = try #require(tableView.headerView(forSection: 0))
        let content = try #require(header.contentConfiguration as? UIListContentConfiguration)
        #expect(content.text == "A")
        #expect(content.textProperties.color == .darkGray)
        #expect(content.directionalLayoutMargins == .init(top: 2.0, leading: 0.0, bottom: 2.0, trailing: 0.0))
    }

    @Test("didSelectRow: deselects row, sends .termChosen")
    func didSelectRow() async throws {
        makeWindow(view: tableView)
        let string1 = "zebra\tenglish zebra\t2\ta\tpart"
        let string2 = "yak\tenglish yak\t1\tb\tpart"
        let string3 = "aardvark\tenglish aardvark\t1\tc\tpart"
        let string4 = "aardvark\tenglish aardvark\t1\tb\tpart"
        let terms = [string1, string2, string3, string4].enumerated().map { Term(tabbedString: $0.1, index: $0.0)}
        await subject.present(.init(terms: terms))
        tableView.selectRow(at: .init(row: 0, section: 0), animated: false, scrollPosition: .none)
        #expect(tableView.indexPathForSelectedRow == IndexPath(row: 0, section: 0))
        // that was prep, this is the test
        subject.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        #expect(tableView.indexPathForSelectedRow == nil)
        #expect(processor.thingsReceived.first == .termChosen(3))
    }
}
