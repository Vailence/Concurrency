import UIKit

class ThreadSafeArrayWithQueue {
	private let firstQueue = DispatchQueue(label: "firstQueue", attributes: .concurrent)
	private let secondQueue = DispatchQueue(label: "secondQueue", attributes: .concurrent)
	private let thirdQueue = DispatchQueue(label: "thirdQueue", attributes: .concurrent)
	private let threadSafeArrayQueue = DispatchQueue(label: "threadSafeArrayQueue")
 
	private var array: [Int] = []

	private func append(n: Int) {
		threadSafeArrayQueue.sync {
			array.append(n)
		}
	}
	
	private func startLoop() {
		for i in 0..<2 {
			self.append(n: i)
		}
	}
	
	func startQueues() {
		firstQueue.async {
			self.startLoop()
		}

		secondQueue.async {
			self.startLoop()
		}
		
		thirdQueue.async {
			self.startLoop()
		}

		Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
			print(self.array)
		}
	}
}

ThreadSafeArrayWithQueue().startQueues()


class ThreadSafeArrayWithBarriers {
	private let firstQueue = DispatchQueue(label: "firstQueue", attributes: .concurrent)
	private let secondQueue = DispatchQueue(label: "secondQueue", attributes: .concurrent)
	private let threadSafeArrayQueue = DispatchQueue(label: "threadSafeArrayQueue")
	
	private var array: [Int] = []
	
	private func append(n: Int) {
		threadSafeArrayQueue.async(flags: .barrier) {
			self.array.append(n)
		}
	}
	
	private func remove(at index: Int) {
		threadSafeArrayQueue.async(flags: .barrier) {
			self.array.remove(at: index)
		}
	}
	
	private func startLoop() {
		for i in 0..<2 {
			self.append(n: i)
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
			print(self.array)
		}
	}
}

ThreadSafeArrayWithBarriers().startQueues()
