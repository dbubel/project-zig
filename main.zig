const std = @import("std");
const net = std.net;

var gpa_server = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 12 }){};
var gpa_client = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 12 }){};

const salloc = gpa_server.allocator();

pub const HttpServer = struct {
    // server: net.StreamServer,
    server: std.http.Server,

    fn handle(request: std.http.Request, response: std.http.Response) void {
        defer response.stream.close();
        _ = request;
    }

    pub fn listen(self: *HttpServer, address: std.net.Address) !void {
        // create our general purpose allocator
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};

        // get an std.mem.Allocator from it
        var alloc = gpa.allocator();
        self.server = std.http.Server.init(alloc, .{ .reuse_address = true });

        defer self.server.deinit();

        try self.server.listen(address);
        while (true) {
            var res = try std.http.Server.accept(&self.server, .{ .allocator = alloc });
            defer res.deinit();
            defer res.reset();
            _ = try res.wait();

            try handleRequest(&res);

            // while (res.reset() != .closing) {
            //     res.wait() catch |err| switch (err) {
            //         error.EndOfStream => continue,
            //         else => return err,
            //     };

            // }
        }
    }
};

fn handleRequest(res: *std.http.Server.Response) !void {
    const body = try res.reader().readAllAlloc(salloc, 8192);
    std.debug.print("printing body {s}\n", .{body});
    std.debug.print("printing route {s}\n", .{res.request.target});
    std.debug.print("printing method {any}\n", .{res.request.method});
    defer salloc.free(body);

    try res.headers.append("content-type", "text/plain");

    try res.do();
    if (res.request.method != .HEAD) {
        try res.writeAll("Hello, ");
        try res.writeAll("World!\n");
        try res.finish();
    }
}
pub fn main() !void {
    var server: HttpServer = undefined;
    try server.listen(try net.Address.parseIp("127.0.0.1", 8080));
}
