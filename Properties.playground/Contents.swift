import Foundation
import SwiftUI
import UIKit

/*:
 # Properties
 Properties are values associated with a particular class, structure, or enumeration.
 */

@MainActor
class PropertiesClass {

    /*:
     **Stored Properties**: constants or variables stored as part of an instance of a class or structure
     */
    
    var length: Int = 50
    
    /*:
     **Lazy Stored Propertie**: property whose initial value is not calculated until it is first accessed. It is always marked `var` because the initial value might not be retrieved until after initialization.
     */
    
    lazy var defaults = UserDefaults()
    
    /*:
     **Computed Properties**: properties that do not store a value; instead uses a getter and (optional) setter to retrieve and set other properties and values indirectly.
     */
    
    var origin = CGPoint(x: 0, y: 0)
    
    var size = CGSize(width: 100, height: 100)
    
    var center: CGPoint {
        get {
            CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
        }
        set {
            origin.x = newValue.x - size.width / 2
            origin.y = newValue.y - size.height / 2
        }
    }
    
    /*:
     **Property Observers**: properties that observe and respond to changes in a value, even if the new value that gets set is the same as the old value.
     */
    
    var totalSteps: Int = 0 {
        willSet {
            print("Setting total steps to \(newValue)")
        }
        didSet {
            if totalSteps > oldValue {
                print("Added \(totalSteps - oldValue) steps")
            }
        }
    }
    
    /*:
     **Type Properties**: the opposite of instance properties - which belong to an instance of a particular type - such that they belong to the type itself (static properties).
     */
    
    static let typeId: String = "ID:0131234"
    
    /*:
     **Closure Initializer**: stored property that is initialized using an immediately executed closure. This is often used in UIKit to create UIView elements.
     */
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .green
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
}
