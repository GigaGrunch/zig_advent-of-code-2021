const std = @import("std");

pub fn main() !void {
    std.debug.print("--- Day 17 ---\n", .{});
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
