const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-8_test-input" else "day-8_real-input";
const line_count = if (use_test_input) 10 else 200;

pub fn main() !void {
    std.debug.print("--- Day 8 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var output_sum: u32 = 0;

    var line_num: u32 = 0;
    while (line_num < line_count):(line_num += 1) {
        var buffer: [100]u8 = undefined;
        const line = try file.reader().readUntilDelimiter(buffer[0..], '\n');
        var outer_split = std.mem.split(u8, line, " | ");

        const patterns = outer_split.next() orelse unreachable;

        var one: []const u8 = undefined; // given by count 2
        var four: []const u8 = undefined; // given by count 4
        var seven: []const u8 = undefined; // given by count 3
        var eight: []const u8 = undefined; // given by count 7
        {
            var patterns_split = std.mem.split(u8, patterns, " ");
            while (patterns_split.next()) |digit| {
                switch (digit.len) {
                    2 => one = digit,
                    4 => four = digit,
                    3 => seven = digit,
                    7 => eight = digit,
                    else => { }
                }
            }
        }

        var three: []const u8 = undefined; // count 5, shares 3 with seven
        var six: []const u8 = undefined; // count 6, shares 2 with seven
        var nine: []const u8 = undefined; // count 6, shares 4 with four
        {
            var patterns_split = std.mem.split(u8, patterns, " ");
            while (patterns_split.next()) |digit| {
                switch (digit.len) {
                    5 => {
                        if (shareCount(digit, seven) == 3) {
                            three = digit;
                        }
                    },
                    6 => {
                        if (shareCount(digit, seven) == 2) {
                            six = digit;
                        }
                        else if (shareCount(digit, four) == 4) {
                            nine = digit;
                        }
                    },
                    else => { }
                }
            }
        }

        var zero: []const u8 = undefined; // count 6, not six or nine
        var five: []const u8 = undefined; // count 5, shares 5 with six
        {
            var patterns_split = std.mem.split(u8, patterns, " ");
            while (patterns_split.next()) |digit| {
                switch (digit.len) {
                    6 => {
                        if (shareCount(digit, six) != 6 and shareCount(digit, nine) != 6) {
                            zero = digit;
                        }
                    },
                    5 => {
                        if (shareCount(digit, six) == 5) {
                            five = digit;
                        }
                    },
                    else => { }
                }
            }
        }

        var two: []const u8 = undefined; // count 5 and not three or five
        {
            var patterns_split = std.mem.split(u8, patterns, " ");
            while (patterns_split.next()) |digit| {
                switch (digit.len) {
                    5 => {
                        if (shareCount(digit, three) != 5 and shareCount(digit, five) != 5) {
                            two = digit;
                        }
                    },
                    else => { }
                }
            }
        }

        const output = outer_split.next() orelse unreachable;
        var output_split = std.mem.split(u8, output, " ");

        var digit_index: u4 = 0;
        while (digit_index < 4):(digit_index += 1) {
            const digit_string = output_split.next() orelse unreachable;
            var digit: u32 = undefined;

            if (equals(digit_string, zero)) {
                digit = 0;
            }
            else if (equals(digit_string, one)) {
                digit = 1;
            }
            else if (equals(digit_string, two)) {
                digit = 2;
            }
            else if (equals(digit_string, three)) {
                digit = 3;
            }
            else if (equals(digit_string, four)) {
                digit = 4;
            }
            else if (equals(digit_string, five)) {
                digit = 5;
            }
            else if (equals(digit_string, six)) {
                digit = 6;
            }
            else if (equals(digit_string, seven)) {
                digit = 7;
            }
            else if (equals(digit_string, eight)) {
                digit = 8;
            }
            else if (equals(digit_string, nine)) {
                digit = 9;
            }

            switch (digit_index) {
                0 => output_sum += digit * 1000,
                1 => output_sum += digit * 100,
                2 => output_sum += digit * 10,
                3 => output_sum += digit,
                else => unreachable
            }
        }
    }

    std.debug.print("total output sum is {}\n", .{ output_sum });
}

fn equals(lhs: []const u8, rhs: []const u8) bool {
    return lhs.len == rhs.len and shareCount(lhs, rhs) == lhs.len;
}

fn shareCount(lhs: []const u8, rhs: []const u8) u32 {
    var count: u32 = 0;
    for (lhs) |l_char| {
        for (rhs) |r_char| {
            if (l_char == r_char) {
                count += 1;
                break;
            }
        }
    }
    return count;
}
