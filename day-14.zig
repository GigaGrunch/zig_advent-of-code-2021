const std = @import("std");

const real_input = @embedFile("day-14_real-input");
const test_input = @embedFile("day-14_test-input");

pub fn main() !void {
    std.debug.print("--- Day 14 ---\n", .{});
    const result = try execute(real_input);
    std.debug.print("most common - least common = {}\n", .{ result });
}

test "test-input" {
    std.debug.print("\n", .{});
    const expected: u32 = 1588;
    const result = try execute(test_input);
    try std.testing.expectEqual(expected, result);
}

fn execute(input: []const u8) !u32 {
    var line_it = std.mem.tokenize(u8, input, "\r\n");
    
    const template = line_it.next() orelse unreachable;

    std.debug.print("template: {s}\n", .{ template });

    return @intCast(u32, input.len);
}
