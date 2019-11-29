import RxSwift

final class Scheduler {
    static var network: ImmediateSchedulerType = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = .userInitiated
        operationQueue.name = "NETWORKSERVICE"
        return OperationQueueScheduler(operationQueue: operationQueue)
    }()
}
