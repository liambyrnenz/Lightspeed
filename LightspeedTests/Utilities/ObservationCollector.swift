//
//  ObservationCollector.swift
//  Lightspeed
//
//  Created by Liam on 15/12/2024.
//

import Foundation

/// An object that can observe a value and collect an expected number of updates to it.
class ObservationCollector<T> {

    private var values: [T] = []

    func run(on value: @autoclosure @escaping () -> T, valuesExpectedCount: Int) async -> [T] {
        await withCheckedContinuation { continuation in
            run(on: value(), valuesExpectedCount: valuesExpectedCount, continuation: continuation)
        }
        return values
    }

    private func run(on value: @autoclosure @escaping () -> T, valuesExpectedCount: Int, continuation: CheckedContinuation<Void, Never>) {
        _ = withObservationTracking(value, onChange: { [weak self] in
            guard let self else { return }
            // This only ever fires once per registration on some value, so upon a change, we need to set up a new registration
            // to catch future changes. This has been done here with a recursive call.
            // More info: https://forums.swift.org/t/how-to-use-observation-to-actually-observe-changes-to-a-property/67591/18
            values.append(value())
            if values.count == valuesExpectedCount {
                // The value captured here from `value` is the current, not new, value (i.e. willSet semantics.)
                // When we reach the amount of expected values, wait a moment and then save the last value (which will
                // have updated in `value` by the time the work item below executes.)
                Task {
                    try? await Task.sleep(for: .seconds(0.1))
                    self.values.append(value())
                    continuation.resume()
                }
            }
            run(on: value(), valuesExpectedCount: valuesExpectedCount, continuation: continuation)
        })
    }


}
