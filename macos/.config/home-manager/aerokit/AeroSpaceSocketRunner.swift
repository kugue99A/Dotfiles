import Darwin
import Foundation

/// Protocol-1 transport for AeroSpace 0.21.x. Upstream v0.1.2 sends unframed
/// JSON, which the server interprets as an unsupported protocol version.
public struct AeroSpaceSocketRunner: CommandRunning {
    private struct ClientRequest: Encodable {
        var args: [String]
        var stdin = ""
        var windowId: UInt32? = ProcessInfo.processInfo.environment["AEROSPACE_WINDOW_ID"].flatMap(UInt32.init)
        var workspace: String? = ProcessInfo.processInfo.environment["AEROSPACE_WORKSPACE"]
    }

    private struct ServerAnswer: Decodable {
        var exitCode: Int32
        var stdout: String
        var stderr: String
    }

    private enum TransportError: Error {
        case socketUnavailable, writeFailed, connectionClosed, unsupportedProtocol, invalidFrame
    }

    public static func defaultSocketPath() -> String {
        "/tmp/bobko.aerospace-\(NSUserName()).sock"
    }

    private let socketPath: String
    private let fallback: any CommandRunning
    private let timeout: TimeInterval

    public init(
        socketPath: String = AeroSpaceSocketRunner.defaultSocketPath(),
        fallback: any CommandRunning = ProcessRunner(),
        timeout: TimeInterval = 10
    ) {
        self.socketPath = socketPath
        self.fallback = fallback
        self.timeout = timeout
    }

    public func run(_ executable: String, arguments: [String]) throws -> ProcessResult {
        let answer: ServerAnswer
        do {
            answer = try request(arguments)
        } catch {
            return try fallback.run(executable, arguments: arguments)
        }
        let result = ProcessResult(standardOutput: answer.stdout, standardError: answer.stderr,
                                   terminationStatus: answer.exitCode)
        guard result.succeeded else {
            throw ProcessRunnerError.nonZeroExit(executable: executable, arguments: arguments, result: result)
        }
        return result
    }

    private func request(_ arguments: [String]) throws -> ServerAnswer {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw TransportError.socketUnavailable }
        defer { close(fd) }
        var limit = timeval(tv_sec: Int(timeout),
                            tv_usec: Int32(timeout.truncatingRemainder(dividingBy: 1) * 1_000_000))
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &limit, socklen_t(MemoryLayout<timeval>.size))
        setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &limit, socklen_t(MemoryLayout<timeval>.size))
        var noSigpipe: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &noSigpipe, socklen_t(MemoryLayout<Int32>.size))

        var address = sockaddr_un()
        address.sun_family = sa_family_t(AF_UNIX)
        let path = Array(socketPath.utf8)
        guard path.count < MemoryLayout.size(ofValue: address.sun_path) else {
            throw TransportError.socketUnavailable
        }
        withUnsafeMutableBytes(of: &address.sun_path) { buffer in
            buffer.baseAddress?.copyMemory(from: path, byteCount: path.count)
        }
        let connected = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard connected == 0 else { throw TransportError.socketUnavailable }

        try sendInteger(1, to: fd)
        guard try readInteger(from: fd) == 1 else { throw TransportError.unsupportedProtocol }
        let payload = try JSONEncoder().encode(ClientRequest(args: arguments))
        try sendInteger(UInt32(payload.count), to: fd)
        try send(payload, to: fd)
        let size = try readInteger(from: fd)
        guard size > 0, size <= 16 * 1024 * 1024 else { throw TransportError.invalidFrame }
        return try JSONDecoder().decode(ServerAnswer.self, from: readExactly(Int(size), from: fd))
    }

    private func sendInteger(_ value: UInt32, to fd: Int32) throws {
        var littleEndian = value.littleEndian
        try send(Data(bytes: &littleEndian, count: MemoryLayout<UInt32>.size), to: fd)
    }

    private func readInteger(from fd: Int32) throws -> UInt32 {
        let data = try readExactly(MemoryLayout<UInt32>.size, from: fd)
        return UInt32(littleEndian: data.withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) })
    }

    private func send(_ data: Data, to fd: Int32) throws {
        try data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            guard let base = buffer.baseAddress else { throw TransportError.writeFailed }
            var offset = 0
            while offset < buffer.count {
                let count = write(fd, base + offset, buffer.count - offset)
                if count > 0 { offset += count }
                else if count == 0 || errno != EINTR { throw TransportError.writeFailed }
            }
        }
    }

    private func readExactly(_ size: Int, from fd: Int32) throws -> Data {
        var data = Data(count: size)
        try data.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
            guard let base = buffer.baseAddress else { throw TransportError.connectionClosed }
            var offset = 0
            while offset < size {
                let count = read(fd, base + offset, size - offset)
                if count > 0 { offset += count }
                else if count == 0 || errno != EINTR { throw TransportError.connectionClosed }
            }
        }
        return data
    }
}
