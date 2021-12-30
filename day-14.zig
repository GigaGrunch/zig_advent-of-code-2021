const std = @import("std");

const real_input = @embedFile("day-14_real-input");
const test_input = @embedFile("day-14_test-input");

pub fn main() !void {
    std.debug.print("--- Day 14 ---\n", .{});
    const result = try execute(real_input, 40);
    std.debug.print("most common - least common = {}\n", .{ result });
}

test "test-input 40" {
    std.debug.print("\n", .{});
    const expected: u64 = 2188189693529;
    const result = try execute(test_input, 40);
    try std.testing.expectEqual(expected, result);
}

test "test-input 10" {
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
    var rules = std.AutoHashMap(u32, Rule).init(alloc.allocator());
    var elements = std.AutoHashMap(u8, u64).init(alloc.allocator());

    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        var rule_it = std.mem.tokenize(u8, line, " ->");
        const pair_string = rule_it.next() orelse unreachable;
        const insert = rule_it.next() orelse unreachable;

        const pair = Pair { .lhs = pair_string[0], .rhs = pair_string[1], };
        const lhs_pair = Pair { .lhs = pair.lhs, .rhs = insert[0] };
        const rhs_pair = Pair { .lhs = insert[0], .rhs = pair.rhs };
        try rules.put(pair.hash(), .{
            .lhs_pair_hash = lhs_pair.hash(),
            .rhs_pair_hash = rhs_pair.hash(),
            .insert_char = insert[0],
        });

        try elements.put(pair.lhs, 0);
        try elements.put(pair.rhs, 0);
    }

    var pairs = std.AutoHashMap(u32, u64).init(alloc.allocator());

    for (template) |char, i| {
        var count = elements.getPtr(char) orelse unreachable;
        count.* += 1;

        if (i < template.len - 1) {
            const pair = Pair {
                .lhs = template[i],
                .rhs = template[i + 1],
            };

            var pair_count = try pairs.getOrPut(pair.hash());
            if (pair_count.found_existing) {
                pair_count.value_ptr.* += 1;
            }
            else {
                pair_count.value_ptr.* = 1;
            }
        }
    }

    var iteration: u32 = 1;
    while (iteration <= iterations):(iteration += 1) {
        var new_pairs = std.AutoHashMap(u32, u64).init(alloc.allocator());
        defer new_pairs.deinit();

        var pair_it = pairs.iterator();
        while (pair_it.next()) |pair| {
            const rule = rules.get(pair.key_ptr.*) orelse unreachable;

            var count = elements.getPtr(rule.insert_char) orelse unreachable;
            count.* += pair.value_ptr.*;

            var lhs_pair_count = try new_pairs.getOrPut(rule.lhs_pair_hash);
            if (lhs_pair_count.found_existing) {
                lhs_pair_count.value_ptr.* += pair.value_ptr.*;
            }
            else {
                lhs_pair_count.value_ptr.* = pair.value_ptr.*;
            }

            var rhs_pair_count = try new_pairs.getOrPut(rule.rhs_pair_hash);
            if (rhs_pair_count.found_existing) {
                rhs_pair_count.value_ptr.* += pair.value_ptr.*;
            }
            else {
                rhs_pair_count.value_ptr.* = pair.value_ptr.*;
            }
        }

        pairs.clearRetainingCapacity();
        var new_pair_it = new_pairs.iterator();
        while (new_pair_it.next()) |pair| {
            try pairs.put(pair.key_ptr.*, pair.value_ptr.*);
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

const Rule = struct {
    insert_char: u8,
    lhs_pair_hash: u32,
    rhs_pair_hash: u32,
};

const Pair = struct {
    lhs: u8,
    rhs: u8,

    pub fn equals(lhs: Pair, rhs: Pair) bool {
        return lhs.lhs == rhs.lhs and lhs.rhs == rhs.rhs;
    }

    pub fn hash(self: Pair) u32 {
        return @intCast(u32, self.lhs) + @intCast(u32, self.rhs) * 100;
    }
};
