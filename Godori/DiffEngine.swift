import Foundation

enum DiffToken {
    case equal(String)
    case insert(String)
    case delete(String)
}

struct DiffEngine {
    // Tokenize by word boundaries, preserving whitespace as tokens
    static func tokenize(_ text: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        for ch in text {
            if ch.isWhitespace {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
                tokens.append(String(ch))
            } else {
                current.append(ch)
            }
        }
        if !current.isEmpty { tokens.append(current) }
        return tokens
    }

    // LCS-based diff on token arrays
    static func diff(old: [String], new: [String]) -> [DiffToken] {
        let m = old.count
        let n = new.count

        // Build LCS table
        var dp = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        for i in 1...max(1, m) where i <= m {
            for j in 1...max(1, n) where j <= n {
                if old[i - 1] == new[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        // Backtrack
        var result: [DiffToken] = []
        var i = m, j = n
        while i > 0 || j > 0 {
            if i > 0 && j > 0 && old[i - 1] == new[j - 1] {
                result.append(.equal(old[i - 1]))
                i -= 1; j -= 1
            } else if j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j]) {
                result.append(.insert(new[j - 1]))
                j -= 1
            } else {
                result.append(.delete(old[i - 1]))
                i -= 1
            }
        }
        return result.reversed()
    }

    static func compute(original: String, revised: String) -> [DiffToken] {
        let oldTokens = tokenize(original)
        let newTokens = tokenize(revised)
        return diff(old: oldTokens, new: newTokens)
    }
}
