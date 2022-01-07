const std = @import("std");
const test_input = @embedFile("day-19_test-input");

pub fn main() !void {
    std.debug.print("--- Day 19 ---\n", .{});
}

test "test-input" {
    const input = test_input;

    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    const scanners = try parseScanners(input, alloc.allocator());

    try std.testing.expectEqual(@as(usize, 5), scanners.len);
    try std.testing.expectEqual(@as(usize, 25), scanners[0].beacons.len);
    try std.testing.expectEqual(@as(usize, 25), scanners[1].beacons.len);
    try std.testing.expectEqual(@as(usize, 26), scanners[2].beacons.len);
    try std.testing.expectEqual(@as(usize, 25), scanners[3].beacons.len);
    try std.testing.expectEqual(@as(usize, 26), scanners[4].beacons.len);
}

fn parseScanners(input: []const u8, allocator: std.mem.Allocator) ![]Scanner {
    var scanners = std.ArrayList(Scanner).init(allocator);
    var beacons = std.ArrayList(Pos).init(allocator);

    var first_beacons = std.ArrayList(usize).init(allocator);
    var current_beacon: usize = 0;
    defer first_beacons.deinit();

    var line_it = std.mem.tokenize(u8, input, "\n\r");
    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        if (std.mem.startsWith(u8, line, "--- scanner ")) {
            try first_beacons.append(current_beacon);
        }
        else {
            const beacon = try parseBeacon(line);
            try beacons.append(beacon);
            current_beacon += 1;
        }
    }

    for (first_beacons.items) |start, i| {
        if (i < first_beacons.items.len - 1) {
            const end = first_beacons.items[i + 1];
            const scanner = Scanner { .beacons = beacons.items[start..end] };
            try scanners.append(scanner);
        }
        else {
            const scanner = Scanner { .beacons = beacons.items[start..] };
            try scanners.append(scanner);
        }
    }

    return scanners.items;
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
    beacons: []Pos,
};

const Pos = struct {
    x: i32,
    y: i32,
    z: i32,
};
