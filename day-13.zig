const std = @import("std");

const real_input = @embedFile("day-13_real-input");
const test_input = @embedFile("day-13_test-input");

pub fn main() !void {
    std.debug.print("--- Day 13 ---\n", .{});
    const result = try execute(real_input);
    std.debug.print("there are {} visible dots\n", .{ result });
}

fn execute(input: []const u8) !u32 {
    var buffer: [1024 * 1024]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(buffer[0..]);

    var points = std.ArrayList(Point).init(alloc.allocator());

    var line_it = std.mem.tokenize(u8, input, "\r\n");
    while (line_it.next()) |line| {
        if (std.mem.startsWith(u8, line, "fold")) break;

        var coords_it = std.mem.tokenize(u8, line, ",");
        const x_string = coords_it.next() orelse unreachable;
        const y_string = coords_it.next() orelse unreachable;
        try points.append(.{
            .x = try std.fmt.parseInt(u16, x_string, 10),
            .y = try std.fmt.parseInt(u16, y_string, 10),
        });
    }

    for (points.items) |point| {
        std.debug.print("({},{}) ", .{ point.x, point.y });
    }
    std.debug.print("\n", .{});

    return 0;
}

const Point = struct {
    x: u16,
    y: u16,
};

test "test-input" {
    std.debug.print("\n", .{});
    const expected: u32 = 17;
    const result = try execute(test_input);
    try std.testing.expectEqual(expected, result);
}
