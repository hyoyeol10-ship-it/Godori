import SwiftUI

struct ContentView: View {
    @State private var originalText = ""
    @State private var revisedText = ""
    @State private var diffTokens: [DiffToken] = []
    @State private var selectedTab = 0
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                inputSection
                compareButton
            }
            .navigationTitle("텍스트 변경 비교")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showResult) {
                ResultSheet(tokens: diffTokens)
            }
        }
    }

    private var inputSection: some View {
        VStack(spacing: 12) {
            TextEditorCard(
                title: "초안",
                placeholder: "원본 텍스트를 입력하세요",
                text: $originalText,
                accentColor: .gray
            )
            TextEditorCard(
                title: "수정안",
                placeholder: "수정된 텍스트를 입력하세요",
                text: $revisedText,
                accentColor: .blue
            )
        }
        .padding()
    }

    private var compareButton: some View {
        Button(action: compare) {
            Label("변경사항 비교하기", systemImage: "arrow.left.arrow.right")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canCompare ? Color.blue : Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(14)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .disabled(!canCompare)
        .animation(.easeInOut(duration: 0.2), value: canCompare)
    }

    private var canCompare: Bool {
        !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !revisedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func compare() {
        diffTokens = DiffEngine.compute(original: originalText, revised: revisedText)
        showResult = true
    }
}

// MARK: - Text Editor Card

struct TextEditorCard: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                Spacer()
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                        .padding(10)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $text)
                    .frame(minHeight: 140, maxHeight: 200)
                    .padding(6)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(accentColor.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Result Sheet

struct ResultSheet: View {
    let tokens: [DiffToken]
    @Environment(\.dismiss) private var dismiss

    var stats: (added: Int, deleted: Int, unchanged: Int) {
        var added = 0, deleted = 0, unchanged = 0
        for token in tokens {
            switch token {
            case .insert: added += 1
            case .delete: deleted += 1
            case .equal: unchanged += 1
            }
        }
        return (added, deleted, unchanged)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                statsBar
                Divider()
                DiffAttributedView(tokens: tokens)
            }
            .navigationTitle("비교 결과")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }

    private var statsBar: some View {
        HStack(spacing: 20) {
            StatBadge(label: "추가", count: stats.added, color: .green)
            StatBadge(label: "삭제", count: stats.deleted, color: .red)
            StatBadge(label: "유지", count: stats.unchanged, color: .secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
    }
}

struct StatBadge: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.caption).foregroundColor(.secondary)
            Text("\(count)").font(.caption.bold()).foregroundColor(color)
        }
    }
}
