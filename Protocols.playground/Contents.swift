import Foundation
import UIKit

/*:
 # Protocols
 Protocols define a blueprint of methods, properties, and other requirements that can be adopted by a class, structure, or enumeration. They enable polymorphism and shared behaviour without inheritance. Protocols declare what confirming types must implement; they can optionally provide a default implementation.
 */

enum Language {
    case english, german, croatian
}

protocol Localizable {
    static var supportedLanguages: [Language] { get }
}

extension Localizable {
    static var supportedLanguages: [Language] {
        [.english]
    }
}

/*:
 ## Class-Constrained Protocols
 Protocols can limit their conformance to subclasses of a specific class. This is common when the protocol uses reference semantics or requires UIKit types.
 */

protocol LocalizableViewController where Self: UIViewController {
    func showLocalizedAlert(text: String)
}

class SettingsViewController: UIViewController, LocalizableViewController {
    func showLocalizedAlert(text: String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        present(alert, animated: true)
    }
}

/*:
 ## Existential Types
 **Existential Type (Boxed Type)**: a value that can hold any concrete type conforming to a protocol. The concrete type is chosen at runtime (by what is assigned or passed in), so the compiler does not know the specific type.
 */

protocol Greetable {
    func greet() -> String
}

struct EnglishGreeter: Greetable {
    func greet() -> String { "Hello" }
}

struct GermanGreeter: Greetable {
    func greet() -> String { "Hallo" }
}

var greeter: any Greetable
greeter = GermanGreeter()
greeter.greet()

/*:
 ## Opaque Types
 **Opaque Type**: the callee chooses a concrete type and hides it from the caller. The implementation always returns the same concrete type for that function. This is like a reverse generic - generic types let the code that calls a function pick the type; opaque types allows the function implementation to pick the type and return it in a way that is abstracted from the code calling the function.
 */

protocol CreditCard {
    associatedtype Identifier
    var id: Identifier { get set }
    var item: Int { get set }
}

struct Visa: CreditCard {
    var id: String = "A"
    var item = 1
}

struct MasterCard: CreditCard {
    var id: Int = 2
    var item = 3
}

func createCreditCard() -> some CreditCard {
    let creditCard = MasterCard()
    return creditCard
}
