import NIO
import NIOHTTP1

class HttpHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    
    private var server: HttpServer
    private var handler: HttpServerHandler
    
    init(server: HttpServer, handler: @escaping HttpServerHandler) {
        self.server = server
        self.handler = handler
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        switch self.unwrapInboundIn(data) {
        case .head(let request):
            let (response, code) = self.handler(self.server, request)
            context.writeAndFlush(self.wrapOutboundOut(
                .head(HTTPResponseHead(version: request.version,
                                       status: code,
                                       headers: HTTPHeaders()))),
                                  promise: nil)
            
            var buf = context.channel.allocator.buffer(capacity: response.utf8.count)
            buf.writeString(response)
            context.writeAndFlush(self.wrapOutboundOut(.body(.byteBuffer(buf))), promise: nil)
            
            let promise: EventLoopPromise<Void> = context.eventLoop.makePromise()
            promise.futureResult.whenComplete {
                (_: Result<Void, Error>) in context.close(promise: nil) }
            
            context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: promise)
        default:
            break
        }
    }
}
