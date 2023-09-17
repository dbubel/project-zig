const std = @import("std");
const net = std.net;

var gpa_server = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 12 }){};
// var gpa_client = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 12 }){};

const salloc = gpa_server.allocator();

pub const HttpServer = struct {
    server: std.http.Server,

    // fn handle(request: std.http.Request, response: std.http.Response) void {
    //     defer response.stream.close();
    //     _ = request;
    // }

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
            while (res.reset() != .closing) {
                res.wait() catch |err| switch (err) {
                    error.EndOfStream => continue,
                    else => return err,
                };

                try handleRequest(&res);
            }
        }
    }
};

fn handleRequest(res: *std.http.Server.Response) !void {
    const log = std.log.scoped(.server);

    log.info("{} {s} {s}", .{ res.request.method, @tagName(res.request.version), res.request.target });

    // if (res.request.headers.contains("expect")) {
    //     if (std.mem.eql(u8, res.request.headers.getFirstValue("expect").?, "100-continue")) {
    //         res.status = .@"continue";
    //         try res.do();
    //         res.status = .ok;
    //     } else {
    //         res.status = .expectation_failed;
    //         try res.do();
    //         return;
    //     }
    // }

    const body = try res.reader().readAllAlloc(salloc, 8192);
    defer salloc.free(body);

    if (res.request.headers.contains("connection")) {
        try res.headers.append("connection", "keep-alive");
    }

    if (std.mem.startsWith(u8, res.request.target, "/get")) {
        if (std.mem.indexOf(u8, res.request.target, "?chunked") != null) {
            res.transfer_encoding = .chunked;
        } else {
            res.transfer_encoding = .{ .content_length = 14 };
        }

        try res.headers.append("content-type", "text/plain");

        try res.do();
        if (res.request.method != .HEAD) {
            try res.writeAll("Hello, ");
            try res.writeAll("World!\n");
            try res.finish();
        } else {
            try std.testing.expectEqual(res.writeAll("errors"), error.NotWriteable);
        }
    }
}

pub fn main() !void {
    var server: HttpServer = undefined;
    try server.listen(try net.Address.parseIp("127.0.0.1", 8080));
}
