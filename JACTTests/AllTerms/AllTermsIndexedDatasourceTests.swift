@testable import Jact
import Testing
import UIKit

struct AllTermsIndexedDatasourceTests {
    @Test("datasource produces correct indexes")
    func correctIndexes() async {
        let tableView = UITableView()
        let subject = AllTermsIndexedDatasource(tableView: tableView) { _, _, _ in return nil }
        var snapshot = subject.snapshot()
        snapshot.appendSections(["Q", "E", "D", "A", "B", "C"])
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
            // result is hard coded
            #expect(result == ["Α Β Γ", "•", "Δ Ε Ζ", "•", "Η Θ Ι", "•", "Κ Λ Μ", "•", "Ν Ξ Ο", "•", "Π Ρ Σ", "•", "Τ Υ Φ", "•", "Χ Ψ Ω"])
        }
        do {
            let result = subject.tableView(tableView, sectionForSectionIndexTitle: "ABC", at: 1)
            #expect(result == 3) // where "A" is
        }
        do {
            let result = subject.tableView(tableView, sectionForSectionIndexTitle: "yoho", at: 1)
            #expect(result == -1) // not found, do nothing when tapped
        }
    }
}
