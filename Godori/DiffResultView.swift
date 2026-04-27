import SwiftUI

struct DiffResultView: View {
    let tokens: [DiffToken]

    var body: some View {
        ScrollView {
            diffText
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }

    private var diffText: Text {
        tokens.reduce(Text("")) { result, token in
            result + styledText(for: token)
        }
    }

    private func styledText(for token: DiffToken) -> Text {
        switch token {
        case .equal(let str):
            return Text(str)
        case .insert(let str):
            return Text(str)
                .foregroundColor(.white)
                .background(Color.green)  // SwiftUI Text background workaround via AttributedString
        case .delete(let str):
            return Text(str)
                .foregroundColor(.white)
                .strikethrough(true, color: .red)
        }
    }
}

// MARK: - AttributedString-based view (iOS 15+, better background support)

struct DiffAttributedView: View {
    let tokens: [DiffToken]

    var attributedString: AttributedString {
        var result = AttributedString()
        for token in tokens {
            switch token {
            case .equal(let str):
                var attr = AttributedString(str)
                attr.foregroundColor = .primary
                result += attr
            case .insert(let str):
                var attr = AttributedString(str)
                attr.foregroundColor = UIColor(red: 0.05, green: 0.45, blue: 0.1, alpha: 1).color
                attr.backgroundColor = UIColor(red: 0.75, green: 0.97, blue: 0.75, alpha: 1).color
                result += attr
            case .delete(let str):
                var attr = AttributedString(str)
                attr.foregroundColor = UIColor(red: 0.6, green: 0.05, blue: 0.05, alpha: 1).color
                attr.backgroundColor = UIColor(red: 0.98, green: 0.78, blue: 0.78, alpha: 1).color
                attr.strikethroughStyle = .single
                result += attr
            }
        }
        return result
    }

    var body: some View {
        ScrollView {
            Text(attributedString)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .textSelection(.enabled)
        }
    }
}

private extension UIColor {
    var color: Color { Color(self) }
}
