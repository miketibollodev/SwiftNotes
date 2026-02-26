import Foundation
import SwiftUI

/*:
 # Attributes
 Attributes are pieces of code that can provide additional information to types and declarations.
 */

/*:
 ## Declaration Attributes
 - `@available`: the platform, OS, or language features for a declaration
 - `@discardableResult`: silences warnings if the return value of a function goes unused.
 - `@dynamicMemberLookup`: allows a class, struct, enum, or protocol to enable members to be looked up by name at runtime.
 - `@frozen`: marks an enum (and structs) to signal their underlying cases will not change in the future.
 - `@main`: marks that a struct, class, or enum is the top-level entry point for program flow.
 - `@objc`: applied to any declaration that can be represented in Objective-C, such as protocols, nongeneric enumerations, properties and methods of classes, etc.
 - `@objcMembers`: applied to a class delcaration to implicitly apply `@objc` attribute to all Objective-C compatible members of the class, extensions, and subclasses.
 - `@preconcurrency`: silences warnings and supresses strict concurrency checks.
 */

/*:
 ## Type Attributes
 - `@autoclosure`: applied to a closure parameter and automatically creates a closure from an expression passed in.
 - `@escaping`: applied to a parameter's type in a function of method declaration to indicate that the parameter's value can outlive the lifetime of the caller.
 */

func myAutoClosure(_ expression: @autoclosure () -> Void) {
    expression()
}

func usingAutoClosure() {
    /*:
     Without `@autoclosure`, our function might look like: `myAutoClosure({ print("Hello!") })`
    */
    myAutoClosure(print("Hello!"))
}
