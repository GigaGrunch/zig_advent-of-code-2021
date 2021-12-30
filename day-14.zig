const std = @import("std");

const real_input = @embedFile("day-14_real-input");
const test_input = @embedFile("day-14_test-input");

pub fn main() !void {
    std.debug.print("--- Day 14 ---\n", .{});
    const result = try execute(real_input, 10);
    std.debug.print("most common - least common = {}\n", .{ result });
}

test "test-input" {
    std.debug.print("\n", .{});
    const expected: u64 = 1588;
    const result = try execute(test_input, 10);
    try std.testing.expectEqual(expected, result);
}

fn execute(input: []const u8, iterations: u32) !u64 {
    var buffer: [1024 * 1024]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(buffer[0..]);

    var line_it = std.mem.tokenize(u8, input, "\r\n");

    const template = line_it.next() orelse unreachable;
    var rules = std.AutoHashMap(u32, u8).init(alloc.allocator());
    var elements = std.AutoHashMap(u8, u64).init(alloc.allocator());

    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        var rule_it = std.mem.tokenize(u8, line, " ->");
        const pair_string = rule_it.next() orelse unreachable;
        const insert = rule_it.next() orelse unreachable;

        const pair = Pair { .lhs = pair_string[0], .rhs = pair_string[1], };
        try rules.put(pair.hash(), insert[0]);

        try elements.put(pair.lhs, 0);
        try elements.put(pair.rhs, 0);
    }

    for (template) |char, i| {
        var count = elements.getPtr(char) orelse unreachable;
        count.* += 1;

        if (i < template.len - 1) {
            try recursePair(&elements, rules, .{
                .lhs = template[i],
                .rhs = template[i + 1],
                .remaining_iterations = iterations,
            });
        }
    }

    var least_common: u64 = std.math.maxInt(u64);
    var most_common: u64 = 0;

    var elements_it = elements.iterator();
    while(elements_it.next()) |element| {
        const char = element.key_ptr.*;
        const count = element.value_ptr.*;
        std.debug.print("{c} occurs {} times\n", .{ char, count });
        if (count < least_common) least_common = count;
        if (count > most_common) most_common = count;
    }
    
    return most_common - least_common;
}

fn recursePair(elements: *std.AutoHashMap(u8, u64), rules: std.AutoHashMap(u32, u8), pair: Pair) @typeInfo(@typeInfo(@TypeOf(std.hash_map.HashMap(u8,u64,std.hash_map.AutoContext(u8),80).put)).Fn.return_type.?).ErrorUnion.error_set!void {
    const insert = rules.get(pair.hash()) orelse unreachable;

    var count = elements.getPtr(insert) orelse unreachable;
    count.* += 1;

    const remaining_iterations = pair.remaining_iterations - 1;
    if (remaining_iterations == 0) return;

    try recursePair(elements, rules, .{
        .lhs = pair.lhs,
        .rhs = insert,
        .remaining_iterations = remaining_iterations,
    });
    try recursePair(elements, rules, .{
        .lhs = insert,
        .rhs = pair.rhs,
        .remaining_iterations = remaining_iterations,
    });
}

const Pair = struct {
    lhs: u8,
    rhs: u8,
    remaining_iterations: u32 = 0,

    pub fn equals(lhs: Pair, rhs: Pair) bool {
        return lhs.lhs == rhs.lhs and lhs.rhs == rhs.rhs;
    }

    pub fn hash(self: Pair) u32 {
        return @intCast(u32, self.lhs) + @intCast(u32, self.rhs) * 100;
    }
};
