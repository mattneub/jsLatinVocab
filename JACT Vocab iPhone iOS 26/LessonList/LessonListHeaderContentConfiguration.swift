import UIKit

/// Content configuration object for our header cell.
struct LessonListHeaderContentConfiguration: UIContentConfiguration, Hashable {
    /// Our settable properties.
    let text: String

    // The rest is boilerplate.

    func makeContentView() -> UIView & UIContentView {
        return LessonListHeaderContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

/// The content view to be used for our header cells.
class LessonListHeaderContentView: UIView, UIContentView {
    /// Our interface objects.
    let label = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: 40)).applying {
        $0.font = UIFont(name:"GillSans-Bold", size:20)
        $0.backgroundColor = .clear
        $0.textColor = .myPaler
    }

    // The rest is boilerplate, except the commented lines.

    init(configuration: LessonListHeaderContentConfiguration) {
        super.init(frame: .zero)
        addSubview(label) // Set up our interface.
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var appliedConfiguration: LessonListHeaderContentConfiguration!

    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfig = newValue as? LessonListHeaderContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    func apply(configuration newConfiguration: LessonListHeaderContentConfiguration) {
        guard appliedConfiguration != newConfiguration else { return }
        appliedConfiguration = newConfiguration
        label.text = newConfiguration.text // Apply the configuration to the interface.
    }
}
