//
//  Helper+Duration.swift
//  NetworkLayer
//
//  Created by Alex.personal on 2/7/25.
//

import Foundation

extension Duration {
    /// Represents the `Duration` in seconds with floating-point precision.
    var asDoubleValue: Double {
        let parts = self.components
        return Double(parts.seconds) +
        Double(parts.attoseconds) / 1_000_000_000_000_000_000.0 // 1e18
    }
}
