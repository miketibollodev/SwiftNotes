import Foundation
import SwiftUI

/*:
 # Property Wrappers
 Property wrappers are a type that wraps a given value to attach additional logic to. It is no different than a property with a getter and a setter, but, it is advantageous in that it can be reused around like we would with a class or structure.
 */

@propertyWrapper struct Capitalized {
    
    private var maxLength: Int
    
    /*:
     This uses an underlying value `storedString` to store the wrapped value. It could easily have been implemented without an additional backing property.
     */
    private var storedString: String
    
    /*:
     Property wrappers must implement a stored property called `wrappedValue`. This is what is used to access the value.
     */
    var wrappedValue: String {
        get { String(storedString.prefix(maxLength)) }
        set { storedString = newValue.capitalized }
    }
    
    /*:
     When setting an initial value for a property, the compiler uses the `init(wrappedValue:)` initializer by default.
     */
    init(wrappedValue: String) {
        self.storedString = wrappedValue.capitalized
        self.maxLength = 12
    }
    
    /*:
     Additional initializers can be created, such that arguments are passed before the property name is defined.
     */
    init(wrappedValue: String, maxLength: Int) {
        self.storedString = wrappedValue.capitalized
        self.maxLength = maxLength
    }
}


/*:
 When property wrappers are used, the compiler generates both the *wrapped value* and the *backing storage property*. Whenever a property is prefixed with an underscore, it is accessing the wrapper itself.
 */

struct SomeView: View {
    
    @Capitalized(maxLength: 24) var firstName: String = "alex"
    
    @Capitalized var lastName: String
    
    init(lastName: String, maxLength: Int) {
        self._lastName = .init(wrappedValue: lastName, maxLength: maxLength)
    }
    
    var body: some View {
        Text(firstName + " " + lastName)
    }
}
