import UIKit

/// View controller that displays a list of lessons for the user to choose one.
class LessonListDrillViewController: UICollectionViewController, ReceiverPresenter {

    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Receiver<LessonListDrillAction>)?

    /// Our data source object. It is lazily created when we receive our first `present` call.
    lazy var datasource: any LessonListDrillDatasourceType<LessonListDrillEffect, LessonListDrillState> = LessonListDrillDatasource(
        collectionView: collectionView,
        processor: processor
    )

    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout:layout)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let clearButton = UIBarButtonItem(image: UIImage(systemName: "eraser"), style:.plain, target:self, action: #selector(clear))
        let drillButton = UIBarButtonItem(title:"Drill", style:.plain, target:self, action: #selector(drill))
        self.navigationItem.leftBarButtonItems = [cancelButton, clearButton]
        self.navigationItem.rightBarButtonItem = drillButton
        self.collectionView.allowsMultipleSelection = true

        collectionView.backgroundColor = .myGolden.withAlphaComponent(1)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.topEdgeEffect.isHidden = true
        overrideUserInterfaceStyle = .light

        Task {
            await processor?.receive(.initialData)
        }
    }

    func present(_ state: LessonListDrillState) async {
        await datasource.present(state)
    }

    func receive(_ effect: LessonListDrillEffect) async {
        await datasource.receive(effect)
    }

    @objc func cancel() {
        Task {
            await processor?.receive(.cancel)
        }
    }

    @objc func clear() {
        Task {
            await processor?.receive(.clear)
        }
    }

    @objc func drill() {
        Task {
            await processor?.receive(.drill)
        }
    }
}

extension LessonListDrillViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(
        _ navigationController: UINavigationController
    ) -> UIInterfaceOrientationMask {
        [.landscape]
    }
}

