import UIKit

/// Chief presenter for the drill module.
final class DrillViewController: UIViewController, ReceiverPresenter {
    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Receiver<DrillAction>)?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }

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

    /// Thermometer displaying progress through the correctly answered cards.
    lazy var prog = UIProgressView(progressViewStyle: .default).applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.progress = 1
        $0.backgroundColor = .black
        $0.trackTintColor = .black
        $0.progressImage = UIImage.imageOfSize(CGSize(width:10, height:10)) {
            if let context = UIGraphicsGetCurrentContext() {
                UIImage(named:"papyrusNewLargeCropped")?.draw(at: .zero)
                let rect = context.boundingBoxOfClipPath.insetBy(dx: 1, dy: 1)
                context.setLineWidth(2)
                context.setStrokeColor(UIColor.black.cgColor)
                context.stroke(rect)
                context.strokeEllipse(in: rect)
            }
        }.resizableImage(withCapInsets: UIEdgeInsets(top: 0,left: 4,bottom: 0,right: 4), resizingMode: .stretch)
    }

    /// Black view sitting behind the progress thermometer.
    lazy var blackView = UIView().applying {
        $0.backgroundColor = .black.withAlphaComponent(0.4)
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
    lazy var datasource: any PageViewControllerDatasourceType<DrillAction, DrillEffect, Term> = DrillDatasource(
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
        Task.immediate {
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
        populateToolbar1()
        toolbar.delegate = self

        // Thermometer.
        self.view.addSubview(prog)
        NSLayoutConstraint.activate([
            prog.bottomAnchor.constraint(equalTo: self.toolbar.topAnchor, constant: -10),
            prog.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            prog.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            prog.heightAnchor.constraint(equalToConstant: 10),
        ])

        // Black view behind the thermometer and toolbar.
        self.view.insertSubview(blackView, belowSubview: toolbar)
        NSLayoutConstraint.activate([
            blackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            blackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            blackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            blackView.topAnchor.constraint(equalTo: self.prog.topAnchor),
        ])
    }

    func populateToolbar1() {
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let up = UIBarButtonItem(image: UIImage(named:"arrowup"), style: .plain, target: self, action: #selector(showEnglish))
        self.toolbar.setItems([cancel, spacer, up], animated:true)
    }

    func populateToolbar2() {
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let wrong = UIBarButtonItem(image: UIImage(named:"cancel"), style: .plain, target: self, action: #selector(wrong))
        let right = UIBarButtonItem(image: UIImage(named:"mycheckmark"), style: .plain, target: self, action: #selector(right))
        self.toolbar.setItems([cancel, spacer, wrong, spacer, right], animated:true)
    }


    func present(_ state: DrillState) async {
        datasource.data = state.terms
    }

    func receive(_ effect: DrillEffect) async {
        switch effect {
        case .done:
            modalTransitionStyle = .flipHorizontal
            blackView.isHidden = true
            prog.isHidden = true
            toolbar.isHidden = true
        case .navigateTo:
            populateToolbar1()
        case .progress(let amount):
            prog.setProgress(amount, animated: true)
        case .showEnglish:
            populateToolbar2()
        }
        await datasource.receive(effect)
    }

    @objc func showEnglish() {
        Task.immediate {
            await processor?.receive(.showEnglish)
        }
    }

    @objc func cancel() {
        Task.immediate {
            await processor?.receive(.cancel)
        }
    }

    @objc func right() {
        Task.immediate {
            await processor?.receive(.right)
        }
    }

    @objc func wrong() {
        Task.immediate {
            await processor?.receive(.wrong)
        }
    }
}

extension DrillViewController: UIToolbarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .bottom
    }
}

