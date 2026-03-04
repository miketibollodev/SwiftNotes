import Combine
import SwiftUI

/*:
 # Combine
 **Combine**: framework for handling asynchronous events over time. Rather than using various patterns like delegates, notifications, or closures, Combine provides a single, unified way to process values as they change. The framework centers around:
 - Publishers
 - Operators
 - Subscribers
 */

/*:
 ## Publishers
 **Publishers (Producers)**: types that can emit values over time to one or more subscribers. Every publisher can emit multiple events of an output value, a successful completion, or a completion with an error. Completions can only be called once.
 
 `Publisher`s are generic over two types:
 - `Publisher.Output` is the type of the output values of the publisher.
 - `Publisher.Failure` is the type of error the publisher can throw if it fails. If it can never fail, it is specified with the `Never` failure type.
 
 Publishers do not emit any values if there are no subscribers subscribed to it. They can run indefinitely or be eventually completed (along with failing).
 */

//: `URLSession` publisher

let url = URL(string: "https://api.github.com/repos/johnsundell/publish")!
let urlPublisher = URLSession.shared.dataTaskPublisher(for: url)

//: Iterable publisher

let customerPublisher = ["A1412", "F14664", "C0090"].publisher

//: `Just`: emits a single value to a subscriber and completes.

let just = Just("Notification")

//: `Future`: asynchronously produces a single value and completes.

let future = Future<Int, Never> { promise in
    Task {
        try! await Task.sleep(nanoseconds: 1_000_000)
        promise(.success(42))
    }
}

// --------------------- //

/*:
 ## Subscribers
 **Subscribers (Consumers)**: the code that receives the values (along with completion or error handling) from publishers.
 
 Combine provides two built-in subscribers:
 - `sink` allows you to provide closures with your code that will receive output values and completions.
 - `assign` allows you to bind the resulting output to some property directly.
 */

//: `sink`

customerPublisher
    .sink(
        //: Called once upon completing, either failing or successful
        receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Completed with error: \(error.localizedDescription)")
            case .finished:
                print("Completed successfully")
            }
        },
        
        //: Can be called multiple times depending on the publisher and values emitted.
        receiveValue: { value in
            print("Received value: \(value)")
        }
    )

//: `assign` basic

class MyClass {
    
    @Published var word: String = ""
    
    var subscriptions = Set<AnyCancellable>()
    
    init() {
        let words = ["The", "sly", "brown", "fox"]
        
        //: Allows the assignment to a property of a specific object
        words.publisher
            .assign(to: \.word, on: self)
            .store(in: &subscriptions)
    }
}

//: `assign` republish: through `@Published` properties, values can be *republished*

let object = MyClass()

object.$word
    .sink { word in
        print("Received word: \(word)")
    }

// --------------------- //

/*:
 ## Cancellable
 `Cancellable` is a protocol that enables memory management for subscriptions. The built-in subscribers conform to `Cancellable`, so when the object is released from memory, it cancels the subscription and releases its resources. Every subscriber returns a `Cancellable`.
 
 Thus, we can "bind" the lifespan of a subscription by storing it in a property on something like a `View` or `ViewController`.
 
 Subscriptions return an instance of `AnyCancellable` as a "cancellation token".
 */

//: Simple cancellable

let myCancellable = customerPublisher
    .sink(
        receiveCompletion: { print($0) },
        receiveValue: { print($0) }
    )

myCancellable.cancel()

//: Storing cancellable

class ViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        let future = Future<Int, Never> { promise in
            promise(.success(Int.random(in: 0...100)))
        }
        
        future
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { print($0) },
                receiveValue: { print($0) }
            )
            .store(in: &cancellables)
    }
}

// --------------------- //

/*:
 ## Custom Subscribers
 
 */

final class IntegerSubscriber: Subscriber {
    
    typealias Input = Int
    
    typealias Failure = Never
    
    func receive(subscription: any Subscription) {
        subscription.request(.max(3))
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        print("Received value: \(input)")
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Received completion: \(completion)")
    }
}

// --------------------- //

/*:
 ## Subjects
 **Subjects**: a type of publisher that allows values to programmatically injected into the stream through the `send` method.
 */

//: `PassthroughSubject`: acts like a simple event stream, passing values through. Useful for adapting existing imperative code to the Combine model.

class MyPassthrough {
        
    var word: String = ""
    
    init() {
        let subject = PassthroughSubject<String, Never>()
        
        let subscription = subject
            .assign(to: \.word, on: self)
        
        subject.send("Hello")
        subject.send("world")
        
        subscription.cancel()
    }
}

//: `CurrentValueSubject`: wraps a single value and publishes a new element whenever the value changes (even if it is the same value). Unlike `PassthroughSubject`, this always holds a value.

class MyCurrent {
    
    var subscriptions = Set<AnyCancellable>()
    
    init() {
        let subject = CurrentValueSubject<Int, Never>(0)
        
        subject
            .sink(receiveValue: { print("New value: \($0)")})
            .store(in: &subscriptions)
    
        subject.send(1)
        subject.send(2)
    }
}

// --------------------- //

/*:
 ## Operators
 **Operators (Transformers)**: methods that change, filter, or combine the data from a publisher before it reaches its destination. They return either the same or a new publisher when declared on the publisher.
 */

/*:
 ### Transforming Operators
 */

class TransformingOperators {
    
    let characters = ["A", "B", "C", "D", "E", "F"]
    
    let numbers = [1, 4, 13, 2, 9, 0]
    
    let optionals = ["A", nil, nil, "D", "E", nil]
    
    var subscriptions = Set<AnyCancellable>()
    
    init() { }
    
    //: `collect`: transforms a stream of individual values from a publisher into a single array. By passing an integer, you can limit the number of elements to put into the array before creating a new one.
    
    func collect() {
        characters.publisher
            .collect(3)
            .sink(
                receiveCompletion: { print($0) },
                receiveValue: { print($0) }
            )
            .store(in: &subscriptions)
    }
    
    //: `map`: works like a standard map for values emitted from a publisher. `tryMap` can be used with a `try` prefix that takes a throwing closure; if an error is thrown it cancels downstream publishers. `flatMap` flattens values from multiple upstream publishers into a single publisher.

    func map() {
        numbers.publisher
            .map { $0 * 2 }
            .sink(
                receiveCompletion: { print($0) },
                receiveValue: { print($0) }
            )
            .store(in: &subscriptions)
    }
    
    func tryMap() {
        characters.publisher
            .tryMap {
                guard let url = URL(string: $0) else {
                    throw URLError(.unknown)
                }
                
                return url
            }
            .sink(
                receiveCompletion: { print($0) },
                receiveValue: { print($0?.absoluteString ?? "Failed") }
            )
            .store(in: &subscriptions)
    }
    
    //: `replaceNil`: receives optional values and replaces `nil` values with another value. Similarly, `replaceEmpty` will replace a value if a publisher completes without emitting a value.
    
    func replaceNil() {
        optionals.publisher
            .eraseToAnyPublisher()
            .replaceNil(with: "-")
            .sink(receiveValue: { print($0) }) // 3
            .store(in: &subscriptions)
    }
    
    //: `scan`: provides the current value emitted by an upstram publisher to a closure along with the last value returned by that closure.
    
    func scan() {
        numbers.publisher
            .scan(0) { previous, current in
                return previous + current
            }
            .sink(receiveValue: { print("Sum: \($0)") })
            .store(in: &subscriptions)
    }
}

/*:
 ### Filtering Operators
 */

struct FilteringOperators {
    
    let characters = ["A", "B", "C", "A", "D", "E", "F", "F"]
    
    let numbers = [1, 4, 13, 2, 9, 0]
    
    let optionals = ["A", nil, nil, "D", "E", nil]
            
    //: `filter`: performs identically to the standard library `filter` method.
    
    func filter() {
        numbers.publisher
            .filter { value in
                value.isMultiple(of: 3)
            }
            .sink(receiveValue: { print($0) })
    }
    
    //: `removeDuplicates`: removes duplicates. Requires no arguments when the values conform to `Equatable`. Otherwise, can use `removeDuplicates(by:)`.
    
    func removeDuplicates() {
        characters.publisher
            .removeDuplicates()
            .sink(receiveValue: { print($0) })
    }
    
    //: `compactMap`: throws away `nil` values.
    
    func compactMap() {
        optionals.publisher
            .compactMap { $0 }
            .sink(receiveValue: { print($0) })
    }
    
    // `first`: takes in as many values as needed until it matches the predicate provided, then, it cancels the subscription and completes.
    
    func first() {
        numbers.publisher
            .first(where: { $0 % 3 == 0 })
            .sink(receiveValue: { print($0) })
    }
    
    // `last`: operates similar to `first`, except it only operates on publishers which are finite. There will be no compiler error thrown, but there will be no result if the publisher does not complete.
    
    func last() {
        numbers.publisher
            .last(where: { $0 % 3 == 0 })
            .sink(receiveValue: { print($0) })
    }
    
    // `dropFirst`: drops the first $n$ values, specified by the `count` parameter.
    
    func dropFirst() {
        characters.publisher
            .dropFirst(3)
            .sink(receiveValue: { print($0) })
    }
    
    // `drop(while:)`: drops values while a condition is met, then, values will flow through and not be dropped.
    
    func dropWhile() {
        numbers.publisher
            .drop(while: { $0 % 3 != 0 })
            .sink(receiveValue: { print($0) })
    }
    
    // `drop(untilOutputFrom:)`: drops values emitted by a publisher until a second publisher starts emitting values.
    
    func dropUntilOutputFrom() {
        let isReady = PassthroughSubject<Void, Never>()
        let taps = PassthroughSubject<Int, Never>()
        
        taps
            .drop(untilOutputFrom: isReady)
            .sink(receiveValue: { print($0) })
        
        (1...5).forEach { n in
            taps.send(n)
            
            if n == 3 {
                isReady.send()
            }
        }
    }
    
    // `prefix`: similar to `drop`, there is a `prefix`, `prefix(while:)`, and `prefix(untilOutputFrom:)` that accepts values until some condition is met.
}

/*:
 ### Combining Operators
 */

struct CombiningOperators {
    
    let characters = ["A", "B", "C", "D", "E", "F"]
    
    let numbers = [1, 4, 13, 2, 9, 0]
    
    let optionals = ["A", nil, nil, "D", "E", nil]
    
    //: `prepend`: adds values that emit before any values from the original publisher. `prepend(Output...)` has a variadic argument, whereas `prepend(Sequence)` takes a `Sequence` type. `prepend(Publisher)` takes the values emitted and prepends them to another - the first publisher will only work after the publisher being prepended sends a `.finished` completion.
    
    func prepend() {
        let negatives = [-100, -99, -98].publisher
        
        numbers.publisher
            .prepend(-2, -1, 0) // Output...
            .prepend([-4, -3]) // Sequence
            .prepend(negatives)
            .sink(receiveValue: { print($0) })
    }
    
    //: `append`: appends values, and has similar functions to `prepend` with `append(Output...)`, `append(Sequence)`, and `append(Publisher)`. However, it appends after the original publisher has completed with a `.finished` event.
    
    func append() {
        let positives = [98, 99, 100]
        
        numbers.publisher
            .append([8, 9])
            .append(10, 11, 12)
            .append(positives)
            .sink(receiveValue: { print($0) })
    }
    
    //: `switchToLatest`: for a publisher that emits other publishers, this switches to the latest sent publisher, and cancels previous subscriptions. This could be helpful for use cases like a user initiating a network request. Before it completes, they trigger another one. This would automatically cancel the first and wait on the second.
    
    func switchToLatest() {
        let publisher1 = PassthroughSubject<Int, Never>()
        let publisher2 = PassthroughSubject<Int, Never>()
        let publisher3 = PassthroughSubject<Int, Never>()
        
        let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
        
        publishers
            .switchToLatest()
            .sink(
                receiveCompletion: { _ in print("Completed!") },
                receiveValue: { print($0) }
            )
        
        publishers.send(publisher1)
        publisher1.send(1)
        publisher1.send(2)

        publishers.send(publisher2)
        publisher1.send(3)
        publisher2.send(4)
        publisher2.send(5)

        publishers.send(publisher3)
        publisher2.send(6)
        publisher3.send(7)
        publisher3.send(8)
        publisher3.send(9)

        publisher3.send(completion: .finished)
        publishers.send(completion: .finished)
    }
    
    //: `merge`: interleaves emissions from different publishers of the same type.
    
    func merge() {
        let publisher1 = PassthroughSubject<Int, Never>()
        let publisher2 = PassthroughSubject<Int, Never>()
        
        publisher1
            .merge(with: publisher2)
            .sink(receiveValue: { print($0) })
    }
    
    //: `combineLatest`: combines publishers of different value types, emitting a tuple with the latest values of *all* publishers whenever *any* emit a value. The `combineLatest` will only emit after all publishers have emitted at least one value.
    
    func combineLatest() {
        let stringPublisher = PassthroughSubject<String, Never>()
        let intPublisher = PassthroughSubject<Int, Never>()
        
        stringPublisher
            .combineLatest(intPublisher)
            .sink(receiveValue: { print($0) })
    }
    
    //: `zip`: combines publishers of different value types, emitting a tuple, but only emits after all publishers have emited a value at the current index.
    
    func zip() {
        let stringPublisher = PassthroughSubject<String, Never>()
        let intPublisher = PassthroughSubject<Int, Never>()
        
        stringPublisher
            .zip(intPublisher)
            .sink(receiveValue: { print($0) })
    }
    
}

// --------------------- //
