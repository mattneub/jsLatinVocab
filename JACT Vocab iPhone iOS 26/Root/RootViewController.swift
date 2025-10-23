import UIKit

/// Chief presenter for the root module.
final class RootViewController: UIViewController, ReceiverPresenter {
    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Receiver<RootAction>)?

    var interfaceOrientations: UIInterfaceOrientationMask = [.landscape] { // see footnote
        didSet {
            if interfaceOrientations != oldValue {
                setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { interfaceOrientations }

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
    ).applying {
        // a page view controller should always contain _some_ view controller
        $0.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
    }

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
        switch effect {
        case .restoreLandscapeOrientation:
            interfaceOrientations = [.landscape]
        default:
            await datasource.receive(effect)
        }
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

    @objc func showAllTermsList() {
        Task {
            await processor?.receive(.showAllTerms)
        }
    }

    @objc func showInfo() {
        Task {
            await processor?.receive(.showInfo)
        }
    }

    @objc func showLessonListDrill() {
        Task {
            await processor?.receive(.showLessonListDrill)
        }
    }
}

extension RootViewController: UIToolbarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .bottom
    }
}

/*
 Footnote: In iOS 26 there's a bug where, if we use normal forced rotation for the all terms view
 controller presentation, both the presented and presenting views _jump_ their views into position
 on presentation/dismissal, presumably in obedience to the safe area.

 However, if we allow these views to _rotate_ naturally, this position change _animates_ nicely
 as part of the rotation. Therefore, the all terms view controller is presented over full screen
 and the root view controller _changes_ from landscape only to landscape and portrait. The user can
 thus rotate after presentation to see more of the list at once.

 We then need, obviously, to set the root view controller back to landscape only on dismissal of
 the all terms view controller. However, there's another bug! If the root view controller's page
 view controller then navigates, the page view controller somehow gets the idea, _after_
 navigating, that it is portrait only. It rotates to portrait and gets stuck there.

 Therefore we do a delicate sleight-of-hand. If the user tapped a word to navigate to, we navigate
 to it _first_, before dismissing; the change in the interface happens behind the scenes.
 The page view controller may think we are in portrait, but that's fine because we _are_ in portrait!
 (If the user tapped the Cancel button, we skip that step, obviously.)
 We then force rotation back to landscape, and as the rotation gets underway, we dismiss.
 This gives a really nice combined rotate-and-dismiss animation.

 The alternative, of course, is to strip out the ability of the all terms view controller to
 appear in portrait in the first place; and I could have done that. But this seems an acceptable
 solution for now.
 */
