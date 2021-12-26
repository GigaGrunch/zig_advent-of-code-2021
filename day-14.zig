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
    var buffer: [1024 * 1024]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(buffer[0..]);

    var line_it = std.mem.tokenize(u8, input, "\r\n");
    const template = line_it.next() orelse unreachable;
    std.debug.print("template: {s}\n", .{ template });

    var rules = std.ArrayList(Rule).init(alloc.allocator());

    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        var rule_it = std.mem.tokenize(u8, line, " ->");
        const inPair = rule_it.next() orelse unreachable;
        const outChar = rule_it.next() orelse unreachable;

        try rules.append(.{
            .inPair = inPair,
            .outChar = outChar[0],
        });
    }

    for (rules.items) |rule| {
        std.debug.print("{s} -> {c}\n", .{ rule.inPair, rule.outChar });
    }

    // var string = std.ArrayList(u8).init(alloc.allocator());
    // try string.appendSlice(template);

    return @intCast(u32, input.len);
}

const Rule = struct {
    inPair: []const u8,
    outChar: u8,
};
