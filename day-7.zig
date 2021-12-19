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

fn quickSort(array: []u16) void {
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
    var array = [_]u16 { 8, 7, 6, 1, 0, 9, 2 };
    quickSort(array[0..]);
}
