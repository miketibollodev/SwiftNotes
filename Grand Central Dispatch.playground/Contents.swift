import Foundation
@preconcurrency import UIKit

/*:
 # Grand Central Dispatch
 Grand Central Dispatch (GCD) is a low-level API for managing concurrent operations. It is built on top of threads, managing a shared thread pool.
 */

/*:
 ## Dispatch Queues
 **Dispatch Queues**: queues where work is submitted, and GCD executes in a FIFO order. Queues can be either serial or concurrent, such that either only one task runs at a time, or they can run in parallel. Queues are thread-safe. There are three main types of queues:
 - Main Queue: serial queue that runs on the main thread. All UI must run on the main queue.
 - Global Queues: concurrent queues shared by the whole system, each with different priorities: high, default, low, and background.
 - Custom Queues: custom serial or concurrent queues; not often used.
 
 **Quality of Service**: rather than stating priority directly for the queues, quality of service (QoS) indicates the importance of a given task, and helps GCD determine the priority to give a task. The classes are:
 - User-Interative: tasks that must complete immediately for a smooth user experience. Used for small workloads and UI updates.
 - User-Initiated: asynchronous tasks that the user has initiated. Used when the user is waiting for immediate results.
 - Utility: long-running task, typically with a user-visible progress indicator. Used for networking, computions, I/O, or continuous data feeds.
 - Background: tasks the user is not directly aware of. Used for prefetching, maintenance, or anything not time sensitive.
 
 **Synchronous and Asynchronous**: queues can either run synchronously, meaning it returns control to the caller after the task completes, or, asynchronously, returning immediately which orders the task to start but does not wait for it to complete.
 */

class ScoreCalculator {
    
    func calculateScore(data: [Int]) -> Int {
        return data.reduce(0, +)
    }
}

class ScoreViewController: UIViewController {
    
    let scorer = ScoreCalculator()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24)
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    let scoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Calculate Score", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scoreLabel)
        view.addSubview(scoreButton)
        
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16)
        ])
        
        scoreButton.addTarget(self, action: #selector(didTapScoreButton), for: .touchUpInside)
    }
    
    @objc private func didTapScoreButton() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let score = self.scorer.calculateScore(data: [1, 2, 3, 4, 5])
            
            DispatchQueue.main.async {
                self.scoreLabel.text = "Score: \(score)"
            }
        }
    }
}
