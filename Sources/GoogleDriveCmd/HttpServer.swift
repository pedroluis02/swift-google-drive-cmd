
import Foundation
import NIO
import NIOHTTP1

typealias HttpServerHandler = (HttpServer, HTTPRequestHead) -> (String, HTTPResponseStatus)

class HttpServer {
    private var channel : Channel!
    private var group : MultiThreadedEventLoopGroup!
    private var threadPool : NIOThreadPool!
    
    private let host: String
    private let port: Int
    
    init(host: String? = nil, port: Int? = nil) {
        self.host = host ?? "::1"
        self.port = port ?? 8080
    }
    
    func start(handler: @escaping HttpServerHandler) throws {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        self.threadPool = NIOThreadPool(numberOfThreads: 1)
        threadPool.start()
        
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
        
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).flatMap {
                    channel.pipeline.addHandler(HttpHandler(server: self, handler: handler))
                }
            }
        
        self.channel = try bootstrap.bind(host: host, port: port).wait()
        if let localAddress = channel.localAddress {
            print("Server started and listening on \(localAddress).")
        }
    }
    
    func stop() {
        MultiThreadedEventLoopGroup.currentEventLoop!.scheduleTask(in: .seconds(0)) {
            _ = self.channel.close()
            try! self.group.syncShutdownGracefully()
            try! self.threadPool.syncShutdownGracefully()
            
            print("Server stopped.")
        }
    }
}
