import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QuizViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isFinished {
                    summaryView
                } else if let card = viewModel.currentCard {
                    quizView(for: card)
                } else {
                    ProgressView("読み込み中…")
                }
            }
            .padding()
            .navigationTitle("Linux クイズ")
        }
    }

    @ViewBuilder
    private func quizView(for card: Flashcard) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(card.question)
                .font(.title2.bold())
            Text(viewModel.progressText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {
                ForEach(Array(card.choices.enumerated()), id: \.offset) { index, choice in
                    Button {
                        viewModel.selectAnswer(at: index)
                    } label: {
                        HStack {
                            Text(choice)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(color(for: index, in: card))
                    .disabled(viewModel.answerState != nil)
                }
            }

            if let state = viewModel.answerState {
                Text(state == .correct ? "正解です!" : "残念…")
                    .font(.headline)
                    .foregroundStyle(state == .correct ? Color.green : Color.red)

                Button(action: viewModel.goToNextQuestion) {
                    Text(viewModel.currentIndex + 1 == viewModel.cards.count ? "結果を見る" : "次の問題へ")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
    }

    private var summaryView: some View {
        VStack(spacing: 24) {
            Text("結果")
                .font(.largeTitle.bold())
            Text("スコア: \(viewModel.score) / \(viewModel.cards.count)")
                .font(.title2)
            Button("もう一度", action: viewModel.reload)
                .buttonStyle(.borderedProminent)
        }
    }

    private func color(for index: Int, in card: Flashcard) -> Color {
        guard let state = viewModel.answerState else {
            return .accentColor
        }

        if index == card.answerIndex {
            return .green
        }

        if state == .incorrect && index == viewModel.selectedIndex {
            return .red
        }

        return .gray
    }
}

#Preview {
    ContentView()
}
