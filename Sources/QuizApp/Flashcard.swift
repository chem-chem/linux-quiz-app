import Foundation

struct Flashcard: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let choices: [String]
    let answerIndex: Int

    init(question: String, choices: [String], answerIndex: Int) {
        self.question = question
        self.choices = choices
        self.answerIndex = answerIndex
    }

    init?(csvRow: [String]) {
        guard csvRow.count >= 6,
              let answerIndex = Int(csvRow[5]),
              (0..<4).contains(answerIndex - 1) else {
            return nil
        }
        self.question = csvRow[0]
        self.choices = Array(csvRow[1...4])
        self.answerIndex = answerIndex - 1
    }
}
