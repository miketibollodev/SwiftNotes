import Combine
import SwiftUI

/*:
 # Combine
 **Combine**: framework for handling asynchronous events over time. Rather than using various patterns like delegates, notifications, or closures, Combine provides a single, unified way to process values as they change.
 
 - **Publishers (Producers)**: types that can emit values over time to one or more subscribers. Every publisher can emit multiple events of an output value, a successful completion, or a completion with an error.
 - **Operators (Transformers)**: methods that change, filter, or combine the data from a publisher before it reaches its destination. They return either the same or a new publisher when declared on the publisher.
 - **Subscribers (Consumers)**: the code that receives the values (along with completion or error handling) from publishers.
 */

/*:
 ## Publishers
 `Publisher`s are generic over two types:
 - `Publisher.Output` is the type of the output values of the publisher.
 - `Publisher.Failure` is the type of error the publisher casn throw if it fails. If it can never fail, it is specified with the `Never` failure type.
 
 Publishers do not emit any values if there are no subscribers subscribed to it. They can run indefinitely or be eventually completed (along with failing).
 */

/*:
 ## Operators
 */

/*:
 ## Subscribers
 Combine provides two built-in subscribers:
 - `sink` allows you to provide closures with your code that will receive output values and completions.
 - `assign` allows you to bind the resulting output to some property directly.
 */

/*:
 ## Cancellable
 `Cancellable` is a protocol that enables memory management for subscriptions. The built-in subscribers conform to `Cancellable`, so when the object is released from memory, it cancels the subscription and releases its resources. Every subscriber returns a `Cancellable`.
 
 Thus, we can "bind" the lifespan of a subscription by storing it in a property on something like a `View` or `ViewController`.
 */

let url = URL(string: "https://api.github.com/repos/johnsundell/publish")!
let publisher = URLSession.shared.dataTaskPublisher(for: url)

let cancellable = publisher.sink(
    receiveCompletion: { completion in // Called once upon completion
        switch completion {
        case .failure(let error):
            print(error)
        case .finished:
            print("Success")
        }
        print(completion)
    },
    receiveValue: { value in // Can be called multiple times
        print(value)
    }
)
