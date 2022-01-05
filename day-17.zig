const std = @import("std");

pub fn main() !void {
    std.debug.print("--- Day 17 ---\n", .{});
}

const Rect = struct {
    min_x: i32,
    max_x: i32,
    min_y: i32,
    max_y: i32,
};

fn parseRect(string: []const u8) !Rect {
    var it = std.mem.tokenize(u8, string, "xy=,. ");
    return Rect {
        .min_x = try nextCoord(&it),
        .max_x = try nextCoord(&it),
        .min_y = try nextCoord(&it),
        .max_y = try nextCoord(&it),
    };
}

fn nextCoord(iterator: anytype) !i32 {
    const string = iterator.next().?;
    return try std.fmt.parseInt(i32, string, 10);
}

test "parseRect" {
    const input = "x=20..30, y=-10..-5";
    const expected = Rect { .min_x = 20, .max_x = 30, .min_y = -10, .max_y = -5 };
    const result = try parseRect(input);
    try std.testing.expectEqual(expected, result);
}

fn removePrefix(string: []const u8) []const u8 {
    const prefix = "target area: ";
    return string[prefix.len..];
}

test "removePrefix" {
    const input = "target area: <this is the stuff>";
    const expected = "<this is the stuff>";
    const result = removePrefix(input);
    try std.testing.expectEqualStrings(expected, result);
}
