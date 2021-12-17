const std = @import("std");

const use_test_input = true;
const filename = if (use_test_input) "day-7_test-input" else "day-7_real-input";
const input_length = if (use_test_input) 10 else 1000;

pub fn main() !void {
    std.debug.print("--- Day 7 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});

    var crab_positions: [input_length]u16 = undefined;
    var i: usize = 0;
    while (i < input_length):(i += 1) {
        var buffer: [4]u8 = undefined;
        const delimiter: u8 = if (i != input_length - 1) ',' else '\n';
        const pos_string = try file.reader().readUntilDelimiter(buffer[0..], delimiter);
        crab_positions[i] = try std.fmt.parseInt(u16, pos_string, 10);
    }

    // quickSort(crab_positions[0..]);
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
