/// Actions sent by presenter(s) to processor.
enum AllTermsAction: Equatable {
    case cancel
    case initialInterface
    case termChosen(Int)
}
