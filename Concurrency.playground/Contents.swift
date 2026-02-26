import Foundation
import SwiftUI

/*:
 # Concurrency
 The concurrency framework concerns two aspects:
 (a) Running asynchronous code, such that code can be suspended and resumed later. This does not imply parallelization.
 (b) Running concurrency code, which means running multiple pieces of code simultaneously. This could be parallel, if there are processors available, but it could mean interleaving. Concurrent code does not necessarily mean parallelization.
 */

/*:
 ## Main Actor
 `@MainActor` is the actor representing the (serial) main thread and all of its data. There is no concurrency on the main actor because it consists of only the main thread (code is isolated to the main actor). By default, programs run on the main thread (declarations and types are all implicitly marked `@MainActor`).
 
 **Data Isolation**: concept that code is isolated to a thread, thus, it cannot be modified outside of the current thread. There are three ways to isolate data:
 - Immutable data is always isolated because constants cannot be modified
 - Data referenced by the only current task is always isolated
 - Data that is protected by an actor is isolated if the code accessing that data is also isolated to the actor
 
 To explicitly state that data is not isolated to a specific actor, we use `nonisolated`. This is primarily used in actors when they have methods that do not mutate shared state, or by libraries to indicate that a function can be called on any actor that the developer implementing the library chooses.
 */

nonisolated func decode(_ data: Data) async {
    // Do some decoding ...
}

/*:
 ## Asynchronous Functions
 Asynchronous functions can be suspended during execution. The function is marked by `async` and points where code can suspend are marked `await`. This stops code from running on the current thread (non-blocking) until the event it waits for happens, then execution resumes.
 
 Asynchronous code can be called from a few places:
 - Code in the body of an `async` function, method, or property
 - Code in the static `main()` method of a class, struct, or enum marked by `@main`
 - Code in an unstructured child task
 
 When there are multiple pieces of asynchronous work to be done, but do not require sequential ordering, we can call them in parallel. To do so, we write `async let` when defining a constant and access it later with `await`. This creates an asynchronous binding - similar to promises in other languages - that promises to be available at some point in the future. Where defined, the asynchronous binding *will start runing their code in parallel*; only when we access them with `await` do we pause execution and wait to ensure their availability.
 */

func fetchImage(_ url: URL) async throws -> Image {
    let (data, response) = try await URLSession.shared.data(from: url)
    let uiImage = UIImage(data: data)
    return Image(uiImage: uiImage!)
}

func fetchImages() async throws -> [Image] {
    let url = URL(string: "https://picsum.photos/300")!
    async let firstImage = fetchImage(url)
    async let secondImage = fetchImage(url)
    
    let images = try await [firstImage, secondImage]
    return images
}

/*:
 ## Asynchronous Sequences
 Sequences allow one element of a collection to be consumed at a time asynchronously, instead of all at once. Each item is marked with `await` to indicate that each iteration can possibly suspend.
 */

func fetchFile() async throws {
    let handle = FileHandle.standardInput
    for try await line in handle.bytes.lines {
        print(line)
    }
}

/*:
 ## Unstructured Concurrency
 Unstructured concurrency involves independent tasks (without parent tasks). Tasks are units of work that can run asynchronously.
 
 `Task` is the type that represents a top-level asynchronous task, meaning it can create an asynchronous context from a synchronous context.
 - `Task(name:priority:operation:)` creates a task that defaults to running with the same actor isolation, priority, and task-local state as the current context.
 - `Task.detached(name:priority:operation:)` creates a detached task, which runs without any actor isolation and does not inherit the current context priority or task-local state.
 */

struct ImageDisplayView: View {
    
    @State private var imageTask: Task<Void, Error>?
    
    @State private var returnImageTask: Task<[Image], Error>?
    
    @State var images: [Image]
    
    var body: some View {
        VStack {
            VStack {
                ForEach(images.indices, id: \.self) { index in
                    images[index]
                }
            }
            
            Button("Download Images") {
                /*:
                 While this task will inherit priority from the main thread, when execution resumes, it can be on any thread. Thus, we need to ensure that anything related to the UI is run on the main thread. Some options we can leverage for this:
                 - Call `MainActor.run()` to explicitly put the code back on the main thread
                 - Wrap the function, property, or class with `@MainActor` to ensure it only runs on the main thread
                 - Capture `@MainActor` in the capture list of the closure (i.e., `Task { @MainActor ... }`)
                 */
                imageTask = Task {
                    let images = try await fetchImages()
                    await MainActor.run {
                        self.images = images
                    }
                }
            }
            
            Button("Store Images") {
                returnImageTask = Task {
                    return try await fetchImages()
                }
                
                Task {
                    let images = try await returnImageTask?.value
                    // Store images ...
                }
            }
            
            Button("Cancel Download") {
                imageTask?.cancel()
            }
        }
    }
}

/*:
 ## Structured Concurrency
 Structured concurrency leverages the hierarchy of tasks to perform work. This explicit relationship between tasks and task groups has some advantages:
 - Parent tasks must wait for its child tasks to complete
 - Child tasks that are set a higher priority will bubble up and escalate their parent priority
 - When a parent task is cancelled, all child tasks are cancelled
 - Task-local values propogate to child tasks automatically
 */

func downloadImage(name: String) async -> Image {
    try! await Task.sleep(for: .seconds(2))
    return Image(name)
}

let images = await withTaskGroup(of: Image.self) { group in
    let names = ["shoe", "candy", "bell"]
    for name in names {
        group.addTask {
            return await downloadImage(name: name)
        }
    }
    
    var images: [Image] = []
    for await image in group {
        images.append(image)
    }
    
    return images
}

/*:
 ## Task Cancellation
 Tasks are cancelled in a cooperative cancellation model. Each task checks whether it has been cancelled at the appropriate points in its execution. Depending on the task, the typical responses include:
 - Throwing `CancellationError`
 - Returning `nil` or an empty collection
 - Returning partially completed work
 
 The two ways a task can check for cancellation and stop running is through `Task.checkCancellation()` or reading the `Task.isCancelled` property. Calling `checkCancellation()` throws an error if the task is cancelled, which could then be used to propogate and stop all of the task's work.
 */

let newImages = await withTaskGroup { group in
    let names = ["shoe", "candy", "bell"]
    for name in names {
        let added = group.addTaskUnlessCancelled {
            Task.isCancelled ? nil : await downloadImage(name: name)
        }
        guard added else { break }
    }
    
    var images: [Image] = []
    for await image in group {
        if let image { images.append(image) }
    }
    
    return images
}

/*:
 ## Sendable Types
 Sendable types are types that are safe to share across threads because it does not have mutable state. To mark a type as being sendable, it must conform to the `Sendable` protocol for declarations, or the `@Sendable` attribute for functions and closures. There are three ways for a type to be considered sendable:
 - The type is a value type
 - The type does not have any mutable state, and its immutable state is made up of other sendable data (i.e., a read-only class with value type properties)
 - The type has code that ensures the safety of its mutable state (i.e., a class marked with `@MainActor`)
 */


/*:
 ## Concurrency
 Concurrency allows work to be executed on a background thread, in parallel with the main thread. Asynchronous code does not introduce concurrency; concurrency concerns task execution. Many APIs like `URLSession` offload work to the background for developers. The `@concurrent` atribute tells the compiler to run the function in the background.
 */

@concurrent
func decodeImage(_ data: Data) async -> Image {
    return Image(uiImage: UIImage(data: data)!)
}
