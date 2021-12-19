const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-8_test-input" else "day-8_real-input";
const line_count = if (use_test_input) 10 else 200;

pub fn main() !void {
    std.debug.print("--- Day 8 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

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

            std.debug.print("one is {s}\n", .{ one });
            std.debug.print("four is {s}\n", .{ four });
            std.debug.print("seven is {s}\n", .{ seven });
            std.debug.print("eight is {s}\n", .{ eight });
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

            std.debug.print("three is {s}\n", .{ three });
            std.debug.print("six is {s}\n", .{ six });
            std.debug.print("nine is {s}\n", .{ nine });
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

            std.debug.print("zero is {s}\n", .{ zero });
            std.debug.print("five is {s}\n", .{ five });
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

            std.debug.print("two is {s}\n", .{ two });
        }

        break;
    }
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
