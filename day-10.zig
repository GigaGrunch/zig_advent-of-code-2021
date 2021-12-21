const std = @import("std");
const quickSort = @import("day-7.zig").quickSort;

const use_test_input = false;
const filename = if (use_test_input) "day-10_test-input" else "day-10_real-input";
const line_count = if (use_test_input) 10 else 94;

pub fn main() !void {
    std.debug.print("--- Day 10 ---\n", .{});

    var scores_buffer: [1024 * 1024]u8 = undefined;
    var scores_allocator = std.heap.FixedBufferAllocator.init(scores_buffer[0..]);
    var line_scores = std.ArrayList(u64).init(scores_allocator.allocator());

    var file = try std.fs.cwd().openFile(filename, .{});
    var line_index: usize = 0;
    while (line_index < line_count):(line_index += 1) {
        var buffer: [1000]u8 = undefined;
        var buffer_allocator = std.heap.FixedBufferAllocator.init(buffer[0..]);
        var parenStack = std.ArrayList(u8).init(buffer_allocator.allocator());

        var line_is_corrupted = false;

        var char = try file.reader().readByte();
        while (char != '\n'):(char = try file.reader().readByte()) {
            var is_open_paren = true;

            switch (char) {
                '(' => try parenStack.append(')'),
                '[' => try parenStack.append(']'),
                '{' => try parenStack.append('}'),
                '<' => try parenStack.append('>'),
                else => is_open_paren = false
            }

            if (!is_open_paren) {
                const expected = parenStack.pop();
                if (char != expected) {
                    line_is_corrupted = true;
                    break;
                }
            }
        }

        if (char != '\n') {
            try file.reader().skipUntilDelimiterOrEof('\n');
        }

        if (!line_is_corrupted) {
            var line_score: u64 = 0;
            while (parenStack.items.len > 0) {
                const expected = parenStack.pop();
                line_score *= 5;
                line_score += getPoints(expected);
            }
            try line_scores.append(line_score);
        }
    }

    quickSort(u64, line_scores.items);
    const middle_score = line_scores.items[line_scores.items.len / 2];

    std.debug.print("middle score is {}\n", .{ middle_score });
}

fn getPoints(char: u8) u64 {
    return switch (char) {
        ')' => 1,
        ']' => 2,
        '}' => 3,
        '>' => 4,
        else => unreachable
    };
}
