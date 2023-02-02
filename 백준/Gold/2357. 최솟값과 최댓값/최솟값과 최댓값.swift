
import Foundation

final class IO {
    private let buffer:[UInt8]
    private var index: Int = 0

    init(fileHandle: FileHandle = FileHandle.standardInput) {

        buffer = Array(try! fileHandle.readToEnd()!)+[UInt8(0)] // 인덱스 범위 넘어가는 것 방지
    }

    @inline(__always) private func read() -> UInt8 {
        defer { index += 1 }

        return buffer[index]
    }

    @inline(__always) func readInt() -> Int {
        var sum = 0
        var now = read()
        var isPositive = true

        while now == 10
                      || now == 32 { now = read() } // 공백과 줄바꿈 무시
        if now == 45 { isPositive.toggle(); now = read() } // 음수 처리
        while now >= 48, now <= 57 {
            sum = sum * 10 + Int(now-48)
            now = read()
        }

        return sum * (isPositive ? 1:-1)
    }

    @inline(__always) func readString() -> String {
        var now = read()

        while now == 10 || now == 32 { now = read() } // 공백과 줄바꿈 무시
        let beginIndex = index-1

        while now != 10,
              now != 32,
              now != 0 { now = read() }

        return String(bytes: Array(buffer[beginIndex..<(index-1)]), encoding: .ascii)!
    }

    @inline(__always) func readByteSequenceWithoutSpaceAndLineFeed() -> [UInt8] {
        var now = read()

        while now == 10 || now == 32 { now = read() } // 공백과 줄바꿈 무시
        let beginIndex = index-1

        while now != 10,
              now != 32,
              now != 0 { now = read() }

        return Array(buffer[beginIndex..<(index-1)])
    }

    @inline(__always) func writeByString(_ output: String) { // wapas
        FileHandle.standardOutput.write(output.data(using: .utf8)!)
    }
}

@discardableResult
func makeMinTree(_ node: Int, _ start: Int, _ end: Int) -> Int {
    if start == end {
        minTree[node] = list[start]
        return minTree[node]
    }
    let mid = (start+end)/2
    minTree[node] = min(makeMinTree(node*2, start, mid), makeMinTree(node*2+1, mid+1, end))
    return minTree[node]
}

func minValue(_ node: Int, _ start: Int, _ end: Int, _ lf: Int, _ ryt: Int) -> Int {
    if ryt < start || lf > end { return Int.max }
    if lf <= start && end <= ryt { return minTree[node] }
    let mid = (start+end) / 2
    return min(minValue(node*2, start, mid, lf, ryt), minValue(node*2+1, mid+1, end, lf, ryt))
}

@discardableResult
func makeMaxTree(_ node: Int, _ start: Int, _ end: Int) -> Int {
    if start == end {
        maxTree[node] = list[start]
        return maxTree[node]
    }
    let mid = (start+end)/2
    maxTree[node] = max(makeMaxTree(node*2, start, mid), makeMaxTree(node*2+1, mid+1, end))
    return maxTree[node]
}

func maxValue(_ node: Int, _ start: Int, _ end: Int, _ lf: Int, _ ryt: Int) -> Int {
    if ryt < start || lf > end { return Int.min }
    if lf <= start && end <= ryt { return maxTree[node] }
    let mid = (start+end) / 2
    return max(maxValue(node*2, start, mid, lf, ryt), maxValue(node*2+1, mid+1, end, lf, ryt))
}


let io = IO()
let (N, M) = (io.readInt(), io.readInt())
var list = [0]; for _ in 0..<N { list.append(io.readInt()) }
var minTree = [Int](repeating: 0, count: N*4)
var maxTree = [Int](repeating: 0, count: N*4)

makeMinTree(1, 1, N)
makeMaxTree(1, 1, N)

var result = ""
for _ in 0..<M {
    let (x, y) = (io.readInt(), io.readInt())
    result += "\(minValue(1, 1, N, x, y)) \(maxValue(1, 1, N, x, y))\n"
}
print(result)