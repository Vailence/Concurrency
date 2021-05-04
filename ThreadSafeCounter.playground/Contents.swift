import UIKit

// MARK: - ThreadSafe Counter with Semaphore
class ThreadSafeCounterWithSemaphore {
	private let firstQueue = DispatchQueue(label: "firstQueue", attributes: .concurrent)
	private let secondQueue = DispatchQueue(label: "secondQueue", attributes: .concurrent)
	private let threadSafeQueue = DispatchQueue(label: "threadSafeQueue")
	private let semaphore = DispatchSemaphore(value: 1)

	var count = 0

	private func get() -> Int {
		semaphore.wait()
		defer {
			semaphore.signal()
		}

		return count
	}

	private func set(x: Int) {
		semaphore.wait()
		defer {
			semaphore.signal()
		}

		count += x
	}

	private func startLoop() {
		for _ in 0..<5 {
			set(x: 1)
		}
	}
	
	func startQueues() {
		firstQueue.async {
			self.startLoop()
		}
		
		secondQueue.async {
			self.startLoop()
		}
		
		Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
			print(self.count)
		}
	}
}

ThreadSafeCounterWithSemaphore().startQueues()


// MARK: - ThreadSafe Counter with Queues
class ThreadSafecounterWithBarrier {
	private let firstQueue = DispatchQueue(label: "firstQueue", attributes: .concurrent)
	private let secondQueue = DispatchQueue(label: "secondQueue", attributes: .concurrent)
	private let threadSafeQueue = DispatchQueue(label: "threadSafeQueue")
	var _tempCounter = 0
	
	private var counter: Int {
		get {
			return threadSafeQueue.sync { [unowned self] in
				self._tempCounter
			}
		}

		set {
			threadSafeQueue.async(flags: .barrier) { [unowned self] in
				self._tempCounter = self._tempCounter + newValue
			}
		}
	}
	
	private func startLoop() {
		for i in 0..<3 {
			counter = i
		}
	}
	
	func startQueues() {
		firstQueue.async {
			for i in 0..<3 {
				self.counter = i
			}
		}

		secondQueue.async {
			for i in 0..<3 {
				self.counter = i
			}
		}
		
		Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
			print(self.counter)
		}
	}
}

ThreadSafecounterWithBarrier().startQueues()
