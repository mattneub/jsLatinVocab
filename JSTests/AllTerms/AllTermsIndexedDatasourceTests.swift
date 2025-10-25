@testable import JSLatin
import Testing
import UIKit

struct AllTermsIndexedDatasourceTests {
    @Test("datasource produces correct indexes")
    func correctIndexes() async {
        let tableView = UITableView()
        let subject = AllTermsIndexedDatasource(tableView: tableView) { _, _, _ in return nil }
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
}
