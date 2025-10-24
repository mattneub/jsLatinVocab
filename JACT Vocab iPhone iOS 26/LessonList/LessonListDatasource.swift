import UIKit

/// Protocol describing the view controller's interaction with the datasource, so we can
/// mock it for testing.
protocol LessonListDatasourceType<State>: Presenter, UICollectionViewDelegate {
    associatedtype State
}

/// Object that functions as data source and delegate for our collection view.
final class LessonListDatasource: NSObject, LessonListDatasourceType {
    typealias State = LessonListState

    /// Processor to whom we can send action messages.
    weak var processor: (any Receiver<LessonListAction>)?

    /// Reuse identifier for the table view cells we will be creating.
    private let reuseIdentifier = "reuseIdentifier"
    private let supplementaryIdentifier = "supplementaryIdentifier"

    init(collectionView: UICollectionView, processor: (any Receiver<LessonListAction>)?) {
        self.processor = processor
        super.init()
        // We're going to use a diffable data source. Register the cell types, make the
        // diffable data source, and set the collection view's data source and delegate.
        collectionView.register(
            UICollectionViewListCell.self, // so that we can use built-in content and background configurations
            forCellWithReuseIdentifier: reuseIdentifier
        )
        collectionView.register(
            UICollectionViewCell.self, // so that we can use custom content configuration
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: supplementaryIdentifier
        )
        datasource = createDataSource(collectionView: collectionView)
        collectionView.dataSource = datasource
        collectionView.delegate = self
        // Also, configure the collection view layout.
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            layout.headerReferenceSize = CGSize(width: 0, height: 40) // only height matters
            layout.itemSize = CGSize(width: 70, height: 45)
        }
    }

    /// Type of the diffable data source.
    typealias Datasource = UICollectionViewDiffableDataSource<String, String>

    /// Retain the diffable data source.
    var datasource: Datasource!

    /// Create the data source and populate it with its initial snapshot. Called by our initializer.
    /// - Parameter collectionView: The collection view.
    /// - Returns: The data source.
    ///
    func createDataSource(collectionView: UICollectionView) -> Datasource {
        // It is crucial to refer to members of `self` by way of `unowned self` here, or we leak.
        let datasource = Datasource(collectionView: collectionView) { [unowned self] collectionView, indexPath, identifier in
            return cellProvider(collectionView, indexPath, identifier)
        }
        datasource.supplementaryViewProvider = { [unowned self] collectionView, kind, indexPath in
            return supplementaryViewProvider(collectionView, kind, indexPath)
        }
        return datasource
    }

    func present(_ state: LessonListState) async {
        configureData(terms: state.terms)
    }

    /// Subroutine of `present`. Given the list of terms, build the sections and items of
    /// the data source.
    /// - Parameter terms: The terms.
    func configureData(terms: [Term]) {
        // We only need to do this once.
        var snapshot = NSDiffableDataSourceSnapshot<String, String>()
        guard snapshot.itemIdentifiers.isEmpty else {
            return
        }
        let terms = terms.sorted { $0.lessonSection < $1.lessonSection }
        // A Group is a section of the collection view. A group's name is the lesson name,
        // and its items are sectionFirstWords within that lesson, preceded by the lesson name.
        class Group {
            init(lesson: String, sections: [String]) {
                self.lesson = lesson
                self.sections = sections
            }
            var lesson: String
            var sections: [String]
        }
        var groups = [Group]()
        var currentLesson = "&&&"
        var currentSection = "&&&"
        for term in terms {
            let lesson = term.lesson
            if lesson != currentLesson {
                currentLesson = lesson
                currentSection = term.sectionFirstWord
                groups.append(Group(lesson: currentLesson, sections: [currentLesson + currentSection]))
            } else {
                let section = term.sectionFirstWord
                if section != currentSection {
                    currentSection = section
                    groups.last?.sections.append(currentLesson + currentSection)
                }
            }
        }
        snapshot.deleteAllItems()
        for group in groups {
            snapshot.appendSections([group.lesson])
            snapshot.appendItems(group.sections)
        }
        datasource.apply(snapshot, animatingDifferences: false)
    }

    /// Cell provider function of the diffable data source.
    /// - Parameters:
    ///   - collectionView: The collection view.
    ///   - indexPath: The index path of the cell.
    ///   - identifier: The item identifier from the data source.
    /// - Returns: A populated configured cell.
    ///
    func cellProvider(
        _ collectionView: UICollectionView,
        _ indexPath: IndexPath,
        _ identifier: String
    ) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as? UICollectionViewListCell else {
            return nil
        }
        cell.contentConfiguration = cell.defaultContentConfiguration().configured {
            $0.text = identifier
            $0.textProperties.font = UIFont(name: "Georgia-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)
            $0.textProperties.alignment = .center
            $0.directionalLayoutMargins = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
        cell.backgroundConfiguration = UIBackgroundConfiguration.listCell().configured {
            $0.backgroundColorTransformer = .init { color in
                if cell.configurationState.isHighlighted || cell.configurationState.isSelected {
                    return UIColor.blue.withAlphaComponent(0.8)
                }
                return .myPaler
            }
            $0.strokeColor = .brown
            $0.strokeWidth = 5
            $0.cornerRadius = 5
        }
        return cell
    }

    /// Header provider function of the diffable data source.
    /// - Parameters:
    ///   - collectionView: The collection view.
    ///   - kind: The kind of supplementary view.
    ///   - indexPath: The index path.
    /// - Returns: A populated header cell.
    ///
    func supplementaryViewProvider(
        _ collectionView: UICollectionView,
        _ kind: String,
        _ indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: self.supplementaryIdentifier,
            for: indexPath
        ) as? UICollectionViewCell else {
            return UICollectionReusableView()
        }
        view.backgroundColor = .black
        let text = datasource.sectionIdentifier(for: indexPath.section) ?? ""
        view.contentConfiguration = LessonListHeaderContentConfiguration(text: text)
        return view
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task {
            try? await unlessTesting {
                try? await Task.sleep(for: .seconds(0.1))
            }
            collectionView.deselectItem(at: indexPath, animated: true)
            if let lessonSection = datasource.itemIdentifier(for: indexPath) {
                await processor?.receive(.selectedLessonSection(lessonSection))
            }
        }
    }
}

extension LessonListDatasource: UICollectionViewDelegateFlowLayout {

    // latin only, make "Introduction" cell wider

    func collectionView(
        _ collectionView: UICollectionView,
        layout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if var size = (layout as? UICollectionViewFlowLayout)?.itemSize {
            if indexPath.section == 0 {
                size.width = 150
            }
            return size
        }
        return .zero // shouldn't happen
    }

    // latin only, suppress header for first section ("Introduction")

    func collectionView(
        _ collectionView: UICollectionView,
        layout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if var size = (layout as? UICollectionViewFlowLayout)?.headerReferenceSize {
            if section == 0 {
                size.height = 0
            }
            return size
        }
        return .zero // shouldn't happen
    }

}
