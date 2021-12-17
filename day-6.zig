const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-6_test-input" else "day-6_real-input";

pub fn main() !void {
    std.debug.print("--- Day 6 ---\n", .{});

    var fish_count = [_]u32 {0} ** 9;

    var file = try std.fs.cwd().openFile(filename, .{});
    while (true) {
        const char = try file.reader().readByte();
        if (char == ',') continue;
        if (char == '\n') break;

        const timer = @intCast(usize, char - '0');
        fish_count[timer] += 1;
    }

    var day: usize = 0;
    while (day < 80):(day += 1) {
        const due_fish = fish_count[0];
        fish_count[0] = fish_count[1];
        fish_count[1] = fish_count[2];
        fish_count[2] = fish_count[3];
        fish_count[3] = fish_count[4];
        fish_count[4] = fish_count[5];
        fish_count[5] = fish_count[6];
        fish_count[6] = fish_count[7] + due_fish;
        fish_count[7] = fish_count[8];
        fish_count[8] = due_fish;
    }

    var total_count: u32 = 0;
    for (fish_count) |count| {
        total_count += count;
    }
    std.debug.print("total fish count after 80 days: {}\n", .{ total_count });
}
