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
    var rules = std.ArrayList(Rule).init(alloc.allocator());
    var elements = std.ArrayList(ElementCount).init(alloc.allocator());

    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        var rule_it = std.mem.tokenize(u8, line, " ->");
        const pair_string = rule_it.next() orelse unreachable;
        const insert = rule_it.next() orelse unreachable;

        const pair = Pair { .lhs = pair_string[0], .rhs = pair_string[1], };
        try rules.append(.{
            .pair = pair,
            .insert = insert[0],
        });

        var lhs_known = false;
        var rhs_known = false;
        for (elements.items) |element| {
            if (element.char == pair.lhs) lhs_known = true;
            if (element.char == pair.rhs) rhs_known = true;
        }
        if (!lhs_known) try elements.append(.{ .char = pair.lhs });
        if (!rhs_known) try elements.append(.{ .char = pair.rhs });
    }

    for (template) |char, i| {
        for (elements.items) |*element| {
            if (element.char == char) {
                element.count += 1;
                break;
            }
        }

        if (i < template.len - 1) {
            recursePair(elements.items, rules.items, .{
                .lhs = template[i],
                .rhs = template[i + 1],
                .remaining_iterations = iterations,
            });
        }
    }

    var least_common: u64 = std.math.maxInt(u64);
    var most_common: u64 = 0;
    for (elements.items) |element| {
        std.debug.print("{c} occurs {} times\n", .{ element.char, element.count });
        if (element.count < least_common) least_common = element.count;
        if (element.count > most_common) most_common = element.count;
    }
    
    return most_common - least_common;
}

fn recursePair(elements: []ElementCount, rules: []Rule, pair: Pair) void {
    const insert = for (rules) |rule| {
        if (rule.pair.equals(pair)) break rule.insert;
    } else unreachable;

    for (elements) |*element| {
        if (element.char == insert) {
            element.count += 1;
            break;
        }
    }

    const remaining_iterations = pair.remaining_iterations - 1;
    if (remaining_iterations == 0) return;

    recursePair(elements, rules, .{
        .lhs = pair.lhs,
        .rhs = insert,
        .remaining_iterations = remaining_iterations,
    });
    recursePair(elements, rules, .{
        .lhs = insert,
        .rhs = pair.rhs,
        .remaining_iterations = remaining_iterations,
    });
}

const ElementCount = struct {
    char: u8 = 0,
    count: u64 = 0,
};

const Pair = struct {
    lhs: u8,
    rhs: u8,
    remaining_iterations: u32 = 0,

    pub fn equals(lhs: Pair, rhs: Pair) bool {
        return lhs.lhs == rhs.lhs and lhs.rhs == rhs.rhs;
    }
};

const Rule = struct {
    pair: Pair,
    insert: u8,
};
