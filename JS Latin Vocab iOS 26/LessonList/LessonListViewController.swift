import UIKit

/// View controller that displays a list of lessons for the user to choose one.
class LessonListViewController: UICollectionViewController, ReceiverPresenter {

    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Receiver<LessonListAction>)?

    /// Our data source object. It is lazily created when we receive our first `present` call.
    lazy var datasource: any LessonListDatasourceType<LessonListState> = LessonListDatasource(
        collectionView: collectionView,
        processor: processor
    )

    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.leftBarButtonItem = cancelButton

        collectionView.backgroundColor = .myGolden.withAlphaComponent(1)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.topEdgeEffect.isHidden = true
        overrideUserInterfaceStyle = .light

        Task.immediate {
            await processor?.receive(.initialData)
        }
    }

    func present(_ state: LessonListState) async {
        await datasource.present(state)
    }

    // from bar button item created earlier
    @objc func cancel(_ sender: Any?) {
        Task.immediate {
            await processor?.receive(.cancel)
        }
    }
}

extension LessonListViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(
        _ navigationController: UINavigationController
    ) -> UIInterfaceOrientationMask {
        [.landscape]
    }
}
