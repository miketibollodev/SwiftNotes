import Foundation
import SwiftUI

/*:
 # Observation
 The `Observation` framework implements the observer design pattern in Swift. This is done using the `@Observable` macro that is available to classes, which replaces the old pattern of `@ObservableObject`, `@EnvironmentObject`, and `@StateObject`.
 
 ## Observable
 `@Observable` allows a class to have its properties observed. `@State` is used with classes or (as of iOS 17) value types to tell views that the instance represents the single source of truth.
 */

@Observable
class MyViewModel {
    
    public var selected: Bool
    public var total: Int
    
    init() {
        self.selected = false
        self.total = 0
    }
}

struct MyView: View {
    
    @State var viewModel: MyViewModel = .init()
    
    var body: some View {
        VStack {
            Button("Increment") {
                viewModel.total += 1
            }
            
            /*:
             We do not pass `$viewModel`, as we are not passing a binding.
             */
            MyNestedView(viewModel: viewModel)
        }
    }
}

/*:
 ## Bindable
 `@Bindable` is used for `@Observable` classes. It tells views to track the properties of the instance that the view reads from that class (not simply all properties).
 
 This is not to be confused with `@Binding`, which is used to create a binding on value types. If `@Binding` were to be misused, it would create a `Binding<MyClass>`, meaning views would only observe changes in the instance of `MyClass`, not changes in the properties of `MyClass`.
 */

struct MyNestedView: View {
    
    @Bindable var viewModel: MyViewModel
    
    var body: some View {
        Button(viewModel.selected ? "Deselect" : "Select") {
            viewModel.selected = !viewModel.selected
        }
    }
}
