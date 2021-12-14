const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var cwd = std.fs.cwd();
    const input = try cwd.readFileAlloc(allocator, "input", 1024*1024*1024);

    std.debug.print("{s}\n", .{ input });
}
