const std = @import("std");
const test_input = @embedFile("day-19_test-input");

pub fn main() !void {
    std.debug.print("--- Day 19 ---\n", .{});
}

test "test-input" {
    const input = test_input;

    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    // var scanners = std.ArrayList(Scanner).init(alloc.allocator());
    // var beacons = std.ArrayList(Pos).init(alloc.allocator());

    var scanner_count: u32 = 0;
    var beacon_count: u32 = 0;

    var line_it = std.mem.tokenize(u8, input, "\n\r");
    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        if (std.mem.startsWith(u8, line, "--- scanner ")) {
            scanner_count += 1;
            continue;
        }

        beacon_count += 1;
    }

    try std.testing.expectEqual(@as(u32, 5), scanner_count);
    try std.testing.expectEqual(@as(u32, 127), beacon_count);
}

const Scanner = struct {
    beacons: []*Pos,
};

const Pos = struct {
    x: i32,
    y: i32,
    z: i32,
};
