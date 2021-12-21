const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-10_test-input" else "day-10_real-input";
const line_count = if (use_test_input) 10 else 94;

pub fn main() !void {
    std.debug.print("--- Day 10 ---\n", .{});

    var score: u32 = 0;

    var file = try std.fs.cwd().openFile(filename, .{});
    var line_index: usize = 0;
    while (line_index < line_count):(line_index += 1) {
        var buffer: [1000]u8 = undefined;
        var buffer_allocator = std.heap.FixedBufferAllocator.init(buffer[0..]);
        var parenStack = std.ArrayList(u8).init(buffer_allocator.allocator());

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
                    score += getPoints(char);
                    break;
                }
            }
        }

        if (char != '\n') {
            try file.reader().skipUntilDelimiterOrEof('\n');
        }
    }

    std.debug.print("total score is {}\n", .{ score });
}

fn getPoints(char: u8) u32 {
    return switch (char) {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
        else => unreachable
    };
}
