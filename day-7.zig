const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-7_test-input" else "day-7_real-input";
const input_length = if (use_test_input) 10 else 1000;

pub fn main() !void {
    std.debug.print("--- Day 7 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var target_lower_bound: u16 = 9999;
    var target_upper_bound: u16 = 0;

    var crab_positions: [input_length]u16 = undefined;
    {
        var i: usize = 0;
        while (i < input_length):(i += 1) {
            var buffer: [4]u8 = undefined;
            const delimiter: u8 = if (i != input_length - 1) ',' else '\n';
            const pos_string = try file.reader().readUntilDelimiter(buffer[0..], delimiter);
            const pos = try std.fmt.parseInt(u16, pos_string, 10);
            crab_positions[i] = pos;
            target_lower_bound = @minimum(target_lower_bound, pos);
            target_upper_bound = @maximum(target_upper_bound, pos);
        }
    }

    var target: u16 = undefined;
    var target_moves: u32 = undefined;

    while (true) {
        target = (target_lower_bound + target_upper_bound) / 2;
        target_moves = countMoves(crab_positions[0..], target);

        if (target > target_lower_bound) {
            const lower_target_moves = countMoves(crab_positions[0..], target - 1);
            if (lower_target_moves < target_moves) {
                target_upper_bound = target - 1;
                continue;
            }
        }

        if (target < target_upper_bound) {
            const upper_target_moves = countMoves(crab_positions[0..], target + 1);
            if (upper_target_moves < target_moves) {
                target_lower_bound = target + 1;
                continue;
            }
        }

        break;
    }

    std.debug.print("target is {} with {} total moves\n", .{ target, target_moves });
}

fn countMoves(positions: []u16, target: u16) u32 {
    var moves: u32 = 0;
    for (positions) |pos| {
        const diff = if (pos < target) target - pos else pos - target;
        var i: u32 = 1;
        while (i <= diff):(i += 1) {
            moves += i;
        }
    }
    return moves;
}
