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
    var beacons = std.ArrayList(Pos).init(alloc.allocator());

    var scanner_count: u32 = 0;

    var line_it = std.mem.tokenize(u8, input, "\n\r");
    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        if (std.mem.startsWith(u8, line, "--- scanner ")) {
            scanner_count += 1;
        }
        else {
            const beacon = try parseBeacon(line);
            try beacons.append(beacon);
        }
    }

    try std.testing.expectEqual(@as(u32, 5), scanner_count);
    try std.testing.expectEqual(@as(usize, 127), beacons.items.len);
}

fn parseBeacon(line: []const u8) !Pos {
    var coord_it = std.mem.tokenize(u8, line, ",");
    return Pos {
        .x = try std.fmt.parseInt(i32, coord_it.next().?, 10),
        .y = try std.fmt.parseInt(i32, coord_it.next().?, 10),
        .z = try std.fmt.parseInt(i32, coord_it.next().?, 10),
    };
}

test "parseBeacon" {
    const input = "-456,654,0";
    const expected = Pos {
        .x = -456,
        .y = 654,
        .z = 0,
    };
    try std.testing.expectEqual(expected, try parseBeacon(input));
}

const Scanner = struct {
    beacons: []*Pos,
};

const Pos = struct {
    x: i32,
    y: i32,
    z: i32,
};
