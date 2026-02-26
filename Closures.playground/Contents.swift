import Foundation
import UIKit

/*:
 # Closures
 Closures are self-contained blocks of code that captures (closes over) values from its environment. Closures are reference types.
 */
let myData: [String] = ["Banana", "Apple", "Orange", "Peach"]

let mySortMethod = { (fruit1: String, fruit2: String) -> Bool in
    return fruit1 < fruit2
}

let mySecondSortMethod: (Int, Int) -> Bool = { int1, int2 in
    return int1 < int2
}

let mySortedData = myData.sorted(by: mySortMethod)

/*:
 ## Capture Lists
 Capture lists specifies the values a closure captures from its environment. Anything that we wish to use inside of a closure must be captured in the capture list. Commonly, the thing that needs to be captured is `self`.
 */

class CounterClass {
    
    var counter = 1
    
    lazy var displayCount: () -> Void = { [weak self] in
        guard let self else { return }
        print(self.counter)
    }
}

/*:
 ## Escaping Closures
 Escaping closures outlive or leave the scope that the closure has been passed (it is called after the function returns). When using escaping closures, it will implicitly capture any objects, values, or functions that are referenced within it. That is to say, `[weak self]` may not be sufficient for our capture lists if we reference other objects and want to remain safe.
 */

class ViewModel {
    
    func fetchData(_ completion: @escaping (Int) -> Void) {
        DispatchQueue.global().async {
            completion(Int.random(in: 0...100))
        }
    }
}

class ViewController: UIViewController {
    
    var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCount()
    }
    
    func getCount() {
        ViewModel().fetchData { [weak self] data in
            guard let self else { return }
            self.label.text = "Count: \(data)"
        }
    }
}

