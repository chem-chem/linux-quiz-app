import Foundation
import Combine

final class QuizViewModel: ObservableObject {
    enum AnswerState {
        case correct
        case incorrect
    }

    @Published private(set) var cards: [Flashcard] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var selectedIndex: Int? = nil
    @Published private(set) var answerState: AnswerState? = nil
    @Published private(set) var isFinished: Bool = false

    var currentCard: Flashcard? {
        guard cards.indices.contains(currentIndex) else { return nil }
        return cards[currentIndex]
    }

    var progressText: String {
        guard !cards.isEmpty, !isFinished else { return "" }
        return "\(currentIndex + 1) / \(cards.count)"
    }

    init(bundle: Bundle = .main) {
        loadCards(from: bundle)
    }

    func reload(bundle: Bundle = .main) {
        currentIndex = 0
        score = 0
        selectedIndex = nil
        answerState = nil
        isFinished = false
        loadCards(from: bundle)
    }

    func selectAnswer(at index: Int) {
        guard let card = currentCard,
              answerState == nil,
              card.choices.indices.contains(index) else {
            return
        }

        selectedIndex = index

        if index == card.answerIndex {
            score += 1
            answerState = .correct
        } else {
            answerState = .incorrect
        }
    }

    func goToNextQuestion() {
        guard !cards.isEmpty else { return }

        if currentIndex + 1 < cards.count {
            currentIndex += 1
            selectedIndex = nil
            answerState = nil
        } else {
            isFinished = true
        }
    }

    private func loadCards(from bundle: Bundle) {
        let csvURL = bundle.url(forResource: "builtin", withExtension: "csv")
        let rows = loadCSVRows(from: csvURL) ?? []
        let loadedCards = rows.compactMap(Flashcard.init(csvRow:))
        if loadedCards.isEmpty {
            cards = Self.sampleCards
        } else {
            cards = loadedCards
        }
        isFinished = cards.isEmpty
    }

    private func loadCSVRows(from url: URL?) -> [[String]]? {
        guard let url = url,
              let data = try? Data(contentsOf: url),
              let csvString = String(data: data, encoding: .utf8) else {
            return nil
        }

        var rows: [[String]] = []
        var currentField = ""
        var currentRow: [String] = []
        var insideQuotes = false

        for character in csvString {
            switch character {
            case "\"":
                insideQuotes.toggle()
            case "," where !insideQuotes:
                currentRow.append(currentField)
                currentField.removeAll(keepingCapacity: true)
            case "\n" where !insideQuotes:
                currentRow.append(currentField)
                rows.append(currentRow)
                currentField = ""
                currentRow = []
            default:
                currentField.append(character)
            }
        }

        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField)
            rows.append(currentRow)
        }

        guard !rows.isEmpty else { return nil }
        return Array(rows.dropFirst())
    }
}

private extension QuizViewModel {
    static let sampleCards: [Flashcard] = [
        Flashcard(question: "サンプル問題", choices: ["選択肢A", "選択肢B", "選択肢C", "選択肢D"], answerIndex: 0)
    ]
}
