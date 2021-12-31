const std = @import("std");
const real_input = @embedFile("day-15_real-input");
const test_input = @embedFile("day-15_test-input");

pub fn main() !void {
    std.debug.print("--- Day 15 ---\n", .{});
    const result = try execute(real_input);
    std.debug.print("lowest total risk is {}\n", .{ result });
}

fn execute(input: []const u8) !u32 {
    assert(input.len > 0, "input is empty");
    return 0;
}

test "test-input" {
    const expected: u32 = 40;
    const result = try execute(test_input);
    try std.testing.expectEqual(expected, result);
}

fn assert(condition: bool, message: []const u8) void {
    if (!condition) {
        @panic(message);
    }
}
