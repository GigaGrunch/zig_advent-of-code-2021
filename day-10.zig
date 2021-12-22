const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-10_test-input" else "day-10_real-input";
const line_count = if (use_test_input) 10 else 94;

pub fn main() !void {
    std.debug.print("--- Day 10 ---\n", .{});

    var scores_buffer: [1024 * 1024]u8 = undefined;
    var scores_allocator = std.heap.FixedBufferAllocator.init(scores_buffer[0..]);
    var line_scores = std.ArrayList(u64).init(scores_allocator.allocator());

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var line_index: usize = 0;
    while (line_index < line_count):(line_index += 1) {
        var buffer: [1000]u8 = undefined;
        var buffer_allocator = std.heap.FixedBufferAllocator.init(buffer[0..]);
        var parenStack = std.ArrayList(u8).init(buffer_allocator.allocator());

        var line_is_corrupted = false;

        var char = try file.reader().readByte();
        while (char != '\r' and char != '\n'):(char = try file.reader().readByte()) {
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

    if (line_scores.items.len == 0) unreachable;

    quickSort(line_scores.items);
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

fn quickSort(array: []u64) void {
    var pivot = array.len - 1;

    var greater: usize = 0;
    var smaller: usize = 0;

    while (true) {
        while (greater < pivot):(greater += 1) {
            if (array[greater] > array[pivot]) {
                break;
            }
        }

        if (smaller < greater) {
            smaller = greater;
        }

        while (smaller < pivot):(smaller += 1) {
            if (array[smaller] < array[pivot]) {
                break;
            }
        }

        if (greater == pivot or smaller == pivot) {
            break;
        }

        const tmp = array[greater];
        array[greater] = array[smaller];
        array[smaller] = tmp;
    }

    {
        const tmp = array[greater];
        array[greater] = array[pivot];
        array[pivot] = tmp;
    }

    if (greater > 0) {
        quickSort(array[0..greater]);
    }
    if (greater < array.len - 1) {
        quickSort(array[(greater + 1)..]);
    }
}

test "sort" {
    var array = [_]u64 { 8, 7, 6, 1, 0, 9, 2 };
    quickSort(array[0..]);
}
