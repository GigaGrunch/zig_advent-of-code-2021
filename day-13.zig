const std = @import("std");

const real_input = @embedFile("day-13_real-input");
const test_input = @embedFile("day-13_test-input");

pub fn main() !void {
    std.debug.print("--- Day 13 ---\n", .{});
    const result = try execute(real_input);
    std.debug.print("there are {} visible dots\n", .{ result });
}

fn execute(_: []const u8) !u32 {
    return 0;
}

test "test-input" {
    const expected: u32 = 17;
    const result = try execute(test_input);
    try std.testing.expectEqual(expected, result);
}
