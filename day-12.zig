const std = @import("std");

const input: enum {
    Test1,
    Test2,
    Test3,
    Real,
} = .Test1;
const filename = switch (input) {
    .Test1 => "day-12_test-input-1",
    else => unreachable
};
const path_count = switch (input) {
    .Test1 => 7,
    else => unreachable
};
const cavename_length = switch (input) {
    .Test1 => 1,
    else => unreachable
};

pub fn main() !void {
    std.debug.print("--- Day 12 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    // var alloc_buffer: [1024 * 1024]u8 = undefined;
    // var alloc = std.heap.FixedBufferAllocator.init(alloc_buffer);

    // var large_caves = std.ArrayList([cavename_length]u8).init(alloc.allocator());
    // var small_caves = std.ArrayList([cavename_length]u8).init(alloc.allocator());
    {
        var cave_buffer: [100]u8 = undefined;
        var path_index: u32 = 0;
        while (path_index < path_count):(path_index += 1) {
            const from_cave = try file.reader().readUntilDelimiter(cave_buffer[0..], '-');
            std.debug.print("{s} -> ", .{ from_cave });

            const to_cave_untrimmed = try file.reader().readUntilDelimiter(cave_buffer[0..], '\n');
            const to_cave = std.mem.trimRight(u8, to_cave_untrimmed, "\r");

            std.debug.print("{s}\n", .{ to_cave });
        }
    }
}

const Path = struct {
    from: []const u8,
    to: []const u8,
};
