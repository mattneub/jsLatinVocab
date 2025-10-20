@testable import Jact
import Testing
import UIKit

struct MyIndexedDatasourceTests {
    @Test("datasource produces correct indexes")
    func correctIndexes() async {
        let tableView = UITableView()
        let subject = MyIndexedDatasource<String, String>(tableView: tableView) { _, _, _ in return nil }
        var snapshot = subject.snapshot()
        snapshot.appendSections(["Manny", "Moe", "Jack"])
        await subject.apply(snapshot, animatingDifferences: false)
        let result = subject.sectionIndexTitles(for: tableView)
        #expect(result == nil) // no index for empty table
        snapshot = subject.snapshot()
        snapshot.appendItems(["Testing"], toSection: "Manny")
        await subject.apply(snapshot, animatingDifferences: false)
        let result2 = subject.sectionIndexTitles(for: tableView)
        #expect(result2 == ["Manny", "Moe", "Jack"])
    }
}
