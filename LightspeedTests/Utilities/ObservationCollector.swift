//
//  ObservationCollector.swift
//  Lightspeed
//
//  Created by Liam on 15/12/2024.
//

import XCTest

/// An object that can observe a value and collect an expected number of updates to it.
class ObservationCollector<T> {

    private(set) var values: [T]

    init() {
        self.values = []
    }

    func runObservation(on value: @autoclosure @escaping () -> T, expectation: XCTestExpectation, valuesExpectedCount: Int) {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.values.append(value())
                    expectation.fulfill()
                }
            }
            runObservation(on: value(), expectation: expectation, valuesExpectedCount: valuesExpectedCount)
        })
    }

}
