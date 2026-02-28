import Foundation

struct PhysicsCategory {
    static let none:      UInt32 = 0
    static let player:    UInt32 = 0b0001  // 1
    static let obstacle:  UInt32 = 0b0010  // 2
    static let scoreZone: UInt32 = 0b0100  // 4
    static let boundary:  UInt32 = 0b1000  // 8
}
