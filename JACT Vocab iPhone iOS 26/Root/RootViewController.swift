import UIKit

/// Chief presenter for the root module.
final class RootViewController: UIViewController, ReceiverPresenter {
    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Receiver<RootAction>)?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    /// Background image view. This may not be seen, but is present just in case.
    lazy var imageView = UIImageView(image: UIImage(named: "papyrusNewLargeCropped")).applying {
        $0.contentMode = .scaleToFill
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Free-standing toolbar at the bottom of the screen.
    lazy var toolbar = UIToolbar().applying {
        $0.frame = CGRect(x: 0, y: 0, width: 100, height: 50) // dummy
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Page view controller occupying the entire screen; the toolbar is in front of it.
    lazy var pageViewController: UIPageViewController = UIPageViewController(
        transitionStyle: .pageCurl,
        navigationOrientation: .horizontal,
        options: [.spineLocation: UIPageViewController.SpineLocation.min.rawValue]
    )

    /// Our data source delegate object.
    lazy var datasource: any PageViewControllerDatasourceType<RootAction, RootEffect, Term> = RootDatasource(
        pageViewController: pageViewController,
        processor: processor
    )

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        Task {
            await processor?.receive(.initialInterface)
        }
    }

    /// Subroutine of `viewDidLoad`. Create the interface.
    private func setup() {
        self.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        // Page view controller and its view.
        if let pageView = pageViewController.view {
            addChild(pageViewController) // dance
            pageView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(pageView)
            NSLayoutConstraint.activate([
                pageView.topAnchor.constraint(equalTo: view.topAnchor),
                pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
            pageViewController.didMove(toParent: self) // dance
            pageViewController.dataSource = datasource
            pageViewController.delegate = datasource
        }

        // Toolbar.
        self.view.addSubview(toolbar)
        self.view.bringSubviewToFront(toolbar) // toolbar is in front of everything
        NSLayoutConstraint.activate([
            toolbar.heightAnchor.constraint(equalToConstant: 50),
            toolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

        // Populate toolbar.
        let spacer = UIBarButtonItem.fixedSpace().applying { $0.width = 30 }
        let hider = UIBarButtonItem(image: UIImage(named:"Key"), style: .plain, target: self, action: #selector(toggleEnglish))
        //let bubbler = UIBarButtonItem(image: UIImage(named:"speechBubble"), style: .plain, target: self, action: #selector(toggleExtraInfo))
        let booker = UIBarButtonItem(image: UIImage(named:"folder"), style: .plain, target: self, action: #selector(showLessonList))
        let seeker = UIBarButtonItem(image: UIImage(named:"magnifier"), style: .plain, target: self, action: #selector(showAllTermsList))
        let bulb = UIBarButtonItem(image: UIImage(named:"bulb"), style: .plain, target: self, action: #selector(showLessonListDrill))
        let info = UIBarButtonItem(image: UIImage(named:"help"), style: .plain, target: self, action: #selector(showInfo))
        let allItems = [hider, spacer, /* bubbler, spacer, */ booker, spacer, seeker, spacer, bulb, spacer, info]
        toolbar.setItems(allItems, animated: false)
        toolbar.delegate = self
    }

    func present(_ state: RootState) async {
        datasource.data = state.terms
    }

    func receive(_ effect: RootEffect) async {
        await datasource.receive(effect)
    }

    /// The user has tapped the hider button (key image).
    @objc func toggleEnglish() {
        Task {
            await processor?.receive(.toggleEnglish)
        }
    }

    @objc func showLessonList() {
        Task {
            await processor?.receive(.showLessonList)
        }
    }

    @objc func showAllTermsList() {}

    @objc func showInfo() {
        Task {
            await processor?.receive(.showInfo)
        }
    }

    @objc func showLessonListDrill() {}
}

extension RootViewController: UIToolbarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .bottom
    }
}
