import Foundation
import SwiftUI

/*:
 # Actors
 Actors are reference types that enable safe access to shared mutable state in concurrent programming environments, without the need to create overhead for locks. Requests sent to an actor are placed in a queue (mailbox), and are processed serially. When you encapsulate data within an actor, it is essentially being isolated from direct access from other parts of the program.
 
 The internal queue of an actor is called a *serial executor*. It is similar to a serial dispatch queue, but does not strictly adhere to a FIFO policy. Instead, it prioritizes tasks based on factors like task priority.
 */

/*:
 ## Cross-Actor Reference
 Cross-actor reference is the process of accessing something within an actor from outside of that actor. When this occurs, the request gets added to the mailbox of the actor.
 
 Properties are not mutable from a cross-actor reference. Cross-actor property sets are possible, but inout operations cannot be supported as an implicit suspension point between the `get` and `set` could introduce race conditions.
 
 By default, functions belonging to an actor are considered potentially asynchronous and therefore do not need to be marked `async`.
 */

actor Account {
    
    let id: UUID = UUID()
    
    var balance: Int = 200
    
    func withdraw(amount: Int) {
        guard balance >= amount else { return }
        self.balance = balance - amount
    }
}

var account = Account()

Task {
    await account.withdraw(amount: 100)
}

/*:
 ## Nonisolated Members
 Nonisolated members allow parts of an actor to be accessed without the need for asynchronous calls. This is useful for properties or methods that do not modify state.
 */

extension Account {
    
    nonisolated func getAccountInformation() -> String {
        return "NUM-" + id.uuidString
    }
    
}

/*:
 ## Global Actors
 Actors like `MainActor` are global singleton instances of the main actor. To define our own global singleton actors, we apply the `@globalActor` attribute to our declaration. It must implement a `static` property named `shared`.
 */

@globalActor
actor MyActor {
    static let shared = MyActor()
}
