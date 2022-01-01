const std = @import("std");
const real_input = @embedFile("day-15_real-input");
const test_input = @embedFile("day-15_test-input");

pub fn main() !void {
    std.debug.print("--- Day 15 ---\n", .{});
    const result = try execute(real_input);
    std.debug.print("lowest total risk is {}\n", .{ result });
}

fn execute(input: []const u8) !u32 {
    var alloc_buffer: [1024 * 1024]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(alloc_buffer[0..]);

    var map = std.ArrayList(Pos).init(alloc.allocator());
    defer map.deinit();

    var input_it = std.mem.tokenize(u8, input, "\r\n");
    while (input_it.next()) |line| {
        if (line.len == 0) continue;

        for (line) |pos_cost_char| {
            const cost = pos_cost_char - '0';
            const pos = Pos {
                .individual_cost = cost,
            };

            try map.append(pos);
        }
    }

    return 0;
}

const Pos = struct {
    individual_cost: u32,
};

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
