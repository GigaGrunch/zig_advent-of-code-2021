const std = @import("std");

const real_input = @embedFile("day-14_real-input");
const test_input = @embedFile("day-14_test-input");

pub fn main() !void {
    std.debug.print("--- Day 14 ---\n", .{});
    const result = try execute(real_input);
    std.debug.print("most common - least common = {}\n", .{ result });
}

test "test-input" {
    const expected: u32 = 1588;
    const result = try execute(test_input);
    try std.testing.expectEqual(expected, result);
}

fn execute(input: []const u8) !u32 {
    var buffer: [1024 * 1024]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(buffer[0..]);

    var line_it = std.mem.tokenize(u8, input, "\r\n");

    const template = line_it.next() orelse unreachable;
    var rules = std.ArrayList(Rule).init(alloc.allocator());

    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        var rule_it = std.mem.tokenize(u8, line, " ->");
        const pair = rule_it.next() orelse unreachable;
        const insert = rule_it.next() orelse unreachable;

        try rules.append(.{
            .lhs = pair[0],
            .rhs = pair[1],
            .insert = insert[0],
        });
    }

    var string = std.ArrayList(u8).init(alloc.allocator());
    try string.appendSlice(template);

    var iteration: u32 = 1;
    while (iteration <= 10):(iteration += 1) {
        var lastString = try std.ArrayList(u8).initCapacity(alloc.allocator(), string.items.len);
        try lastString.appendSlice(string.items);
        defer lastString.deinit();

        string.clearRetainingCapacity();

        for (lastString.items) |char, i| {
            try string.append(char);

            if (i < lastString.items.len - 1) {
                for (rules.items) |rule| {
                    if (rule.lhs == char and rule.rhs == lastString.items[i + 1]) {
                        try string.append(rule.insert);
                        break;
                    }
                }
            }
        }
    }

    var element_counts = std.ArrayList(ElementCount).init(alloc.allocator());
    for (string.items) |char| {
        if (!for (element_counts.items) |*item| {
            if (item.element == char) {
                item.count += 1;
                break true;
            }
        } else false) {
            try element_counts.append(.{
                .element = char,
                .count = 1,
            });
        }
    }

    var least_common: u32 = std.math.maxInt(u32);
    var most_common: u32 = 0;
    for (element_counts.items) |item| {
        if (item.count > most_common) {
            most_common = item.count;
        }
        if (item.count < least_common) {
            least_common = item.count;
        }
    }

    const result = most_common - least_common;
    return result;
}

const Rule = struct {
    lhs: u8,
    rhs: u8,
    insert: u8,
};

const ElementCount = struct {
    element: u8,
    count: u32,
};
