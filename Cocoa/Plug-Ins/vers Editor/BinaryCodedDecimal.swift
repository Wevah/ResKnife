//
//  BinaryCodedDecimal.swift
//  vers Editor
//
//  Created by Nate Weaver on 2020-06-22.
//

import Foundation

enum BCDError: Error, CustomDebugStringConvertible {
	enum Key: String {
		case bcd
		case int
		case count
		case actualCount
	}

	case bcdDigitTooBig([Key: Any])
	case notRepresentableInByteCount([Key: Any])
	case negative([Key: Any])

	var debugDescription: String {
		switch self {
			case let .bcdDigitTooBig(dict):
				return "A hex digit in \(dict[.bcd]!) is larger than 9."
			case let .notRepresentableInByteCount(dict):
				return "\(dict[.int]!) cannot be represented as BCD in \(dict[.count]!) byte(s) (requires at least \(dict[.actualCount]!) bytes)."
			case let .negative(dict):
				return "\(dict[.int]!) is negative."
		}
	}
}

extension FixedWidthInteger {

	/// Create an integer from a (big-endian) binary-coded-decimal representation
	///
	/// Example:
	/// ```
	/// let int = Int(binaryCodedDecimal: [0x16, 0x04])
	/// // int is 1604
	/// ```
	/// - Parameter bcd: The binary-coded-decimal representation.
	/// - Throws: BCDError.bcdDigitTooBig if any nibble of `bcd` is greater than 9.
	init<T>(binaryCodedDecimal bcd: T) throws where T: DataProtocol {
		var result: Self = 0
		var multiplier: Self = 1

		for byte in bcd.reversed() {
			result += Self(byte & 0xf) * multiplier
			result += Self(byte >> 4) * multiplier * 10
			multiplier *= 100
		}

		guard result < multiplier else { throw BCDError.bcdDigitTooBig([.bcd: bcd]) }

		self = result
	}

	/// Create a binary-coded-decimal representation of an integer.
	///
	/// Example:
	/// ```
	/// let bcd = 1604.binaryCodedDecimal()
	/// // bcd is [0x16, 0x04]
	/// ```
	/// - Parameter byteCount: The byte count of the final representation.
	///   If `0`, there is no limit or padding.
	/// - Throws:
	///   - `BCDError.negative` if `self` is negative.
	///   - `BCDError.notRepresentableInByteCount` if `self` would require more than `byteCount` bytes.
	/// - Returns: A (big-endian) binary-coded-decimal representation of `self`, padded to `byteCount` bytes.
	func binaryCodedDecimal(byteCount: Int = 0) throws -> [UInt8] {
		guard self >= 0 else { throw BCDError.negative([.int: self]) }

		var copy = self

		var bcd = [UInt8]()

		while copy != 0 {
			var byte: UInt8 = UInt8(copy % 10)
			copy /= 10
			byte |= UInt8(copy % 10) << 4
			copy /= 10
			bcd.insert(byte, at: 0)
		}

		if byteCount > 0 {
			guard bcd.count <= byteCount else {
				throw BCDError.notRepresentableInByteCount([.int: self, .count: byteCount, .actualCount: bcd.count])
			}

			if byteCount > bcd.count {
				for _ in bcd.count..<byteCount {
					bcd.insert(0x0, at: 0)
				}
			}
		}

		return bcd
	}
}
