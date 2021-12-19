const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-8_test-input" else "day-8_real-input";
const line_count = if (use_test_input) 10 else 200;

const one_segment_count = 2;
const four_segment_count = 4;
const seven_segment_count = 3;
const eight_segment_count = 7;

// 1: given by count 2            iteration 0
// 4: given by count 4            iteration 0
// 7: given by count 3            iteration 0
// 8: given by count 7            iteration 0

// 3: count 5 and shares 3 with 7 (DEP 7)
// 5: count 5 and shares 5 with 6 (DEP 6)
// 6: count 6 and shares 2 with 7 (DEP 7)
// 9: count 6 and shares 4 with 4 (DEP 4)

// 0: const 6 and not 6 or 9      (DEP 6,9)
// 2: count 5 and not 3 or 5      (DEP 3,5)

pub fn main() !void {
    std.debug.print("--- Day 8 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var one_count: u32 = 0;
    var four_count: u32 = 0;
    var seven_count: u32 = 0;
    var eight_count: u32 = 0;

    var line_num: u32 = 0;
    while (line_num < line_count):(line_num += 1) {
        var buffer: [100]u8 = undefined;
        const line = try file.reader().readUntilDelimiter(buffer[0..], '\n');
        var outer_split = std.mem.split(u8, line, " | ");
        _ = outer_split.next();
        const output = outer_split.next() orelse unreachable;
        var output_split = std.mem.split(u8, output, " ");
        while (output_split.next()) |digit| {
            switch (digit.len) {
                one_segment_count => one_count += 1,
                four_segment_count => four_count += 1,
                seven_segment_count => seven_count += 1,
                eight_segment_count => eight_count += 1,
                else => { }
            }
        }
    }

    const total_count = one_count + four_count + seven_count + eight_count;
    std.debug.print("total numbers with unique segment count: {}\n", .{ total_count });
}
