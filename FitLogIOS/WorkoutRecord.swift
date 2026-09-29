import Foundation
import SwiftData

@Model
final class WorkoutRecord {
    var timestamp: Date
    var exercise: String
    var weight: Double?
    var sets: Int?
    var reps: Int?
    var note: String

    init(timestamp: Date, exercise: String, weight: Double? = nil, sets: Int? = nil, reps: Int? = nil, note: String = "") {
        self.timestamp = timestamp
        self.exercise = exercise
        self.weight = weight
        self.sets = sets
        self.reps = reps
        self.note = note
    }
}
