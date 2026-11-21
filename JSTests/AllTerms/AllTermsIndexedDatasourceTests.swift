@testable import JSLatin
import Testing
import UIKit
import WaitWhile

struct AllTermsIndexedDatasourceTests {
    @Test("datasource produces correct indexes")
    func correctIndexes() async {
        let tableView = UITableView()
        makeWindow(view: tableView)
        let subject = AllTermsIndexedDatasource(tableView: tableView) { _, _, _ in return UITableViewCell() }
        var snapshot = subject.snapshot()
        snapshot.appendSections(["Q", "E", "D"])
        await subject.apply(snapshot, animatingDifferences: false)
        do {
            let result = subject.sectionIndexTitles(for: tableView)
            #expect(result == nil) // no index for empty table
        }
        snapshot = subject.snapshot()
        snapshot.appendItems([1], toSection: "Q")
        await subject.apply(snapshot, animatingDifferences: false)
        do {
            let result = subject.sectionIndexTitles(for: tableView)
            #expect(result == ["Q\u{2800}", "E\u{2800}", "D\u{2800}"])
        }
        do {
            let result = subject.tableView(tableView, sectionForSectionIndexTitle: "E\u{2800}", at: 1)
            #expect(result == 1) // where "E" is
        }
        do {
            let result = subject.tableView(tableView, sectionForSectionIndexTitle: "yoho", at: 1)
            #expect(result == -1) // not found, do nothing when tapped
        }
    }

    @Test("datasource produces correct indexes on iPad")
    func correctIndexesPad() async {
        let tableView = UITableView()
        let window = makeWindow(view: tableView)
        window.traitOverrides[UITraitUserInterfaceIdiom.self] = .pad
        await #while(tableView.traitCollection.userInterfaceIdiom != .pad)
        let subject = AllTermsIndexedDatasource(tableView: tableView) { _, _, _ in return UITableViewCell() }
        var snapshot = subject.snapshot()
        snapshot.appendSections(["Q", "E", "D"])
        await subject.apply(snapshot, animatingDifferences: false)
        do {
            let result = subject.sectionIndexTitles(for: tableView)
            #expect(result == nil) // no index for empty table
        }
        snapshot = subject.snapshot()
        snapshot.appendItems([1], toSection: "Q")
        await subject.apply(snapshot, animatingDifferences: false)
        do {
            let result = subject.sectionIndexTitles(for: tableView)
            let expected: [String] = [
                "A B C", "•", "D E F", "•", "G H I", "•", "L M N", "•",
                "O P Q", "•", "R S T", "•", "U"
            ]
            #expect(result == expected)
        }
        do {
            let result = subject.tableView(tableView, sectionForSectionIndexTitle: "D E F", at: 2)
            #expect(result == 2) // where "D" is
        }
        do {
            let result = subject.tableView(tableView, sectionForSectionIndexTitle: "•", at: 1)
            #expect(result == -1) // not found, do nothing when tapped
        }
    }
}
