import Foundation
import SwiftUI

/*:
 # Environment
 The SwiftUI environment is a dependency injection pattern that allows data to be shared across views in the view hierarchy. This could take the form of a function, a state, a value type, or a reference type.
 */

/*:
 ## Predefined Values
 SwiftUI includes various predefined values stored in the `EnvironmentValues` struct, such as `verticalSizeClass`, `dismiss`, and `locale`.
 */

/*:
 ## Reading Environment
 Values are read using the `@Environment` property wrapper. While some values are read-only, an environment value is set using the `environment()` modifier. From the point this modifier is called, it propogates strictly downwards into the child views. This is why we often inject into the environment at the app entry point.
 */

/*:
 ## Custom Environment Values
 Environment values are added by extending `EnvironmentValues` and defining a property with the `@Entry` macro. This creates an environment key with a default value.
 
 Alternatively, we can simply inject the type itself as a key without extending `EnvironmentValues` (shown in next section). This is *only* to be used when we expect there to only be one instance of the specific type in the environment.
 */

extension EnvironmentValues {
    
    /*:
     This creates an environment value with a default value that we primarily seek to be read-only.
     */
    @Entry var colorFill: Color = .blue
}

struct ColorsView: View {
    
    @Environment(\.colorFill) var colorFill
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 50, height: 50)
                .foregroundStyle(colorFill)
        }
    }
}

/*:
 ## Observation
 Reference types can also be injected into the environment using `Observation`. This example showcases the alternate way to inject into the environment.
 */

@Observable
class DataModel {
    var count = 0
}

struct MyApp: App {
    
    /*:
     This is a `@State` marked property, because if `MyApp` (or whatever top level view is used) is redrawn, the instance gets recreated. As a general rule, if we want persistant state, then you need `@State`.
     */
    @State var dataModel = DataModel()
    
    var body: some Scene {
        WindowGroup {
            Rectangle()
        }
        .environment(dataModel)
    }
}

struct ContentView: View {
    
    @Environment(DataModel.self) private var dataModel
    
    var body: some View {
        Text("Count: \(dataModel.count)")
    }
}

