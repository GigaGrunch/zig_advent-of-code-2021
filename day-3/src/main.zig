const std = @import("std");

const use_test_input = true;
const filename = if (use_test_input) "test_input" else "real_input";
const sample_count = if (use_test_input) 12 else 1000;
const sample_length = if (use_test_input) 5 else 12;

pub fn main() !void {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(filename, .{});
    defer file.close();

    var file_text: [sample_count * (sample_length + 1) + 1]u8 = undefined;
    _ = try file.readAll(file_text[0..]);

    const samples = getSamples(file_text[0..]);

    try powerConsumption(samples[0..]);
    try lifeSupportRating(samples[0..]);
}

fn getSamples(file_text: []const u8) [sample_count][]const u8 {
    var samples: [sample_count][]const u8 = undefined;
    var sample_index: usize = 0;
    while (sample_index < sample_count):(sample_index += 1) {
        const start = sample_index * (sample_length + 1);
        const end = start + sample_length;
        samples[sample_index] = file_text[start..end];
    }
    return samples;
}

fn powerConsumption(samples: []const []const u8) !void {
    var one_counts = [_]u32{0} ** sample_length;
    for (samples) |sample| {
        for (sample) |char, i| {
            if (char == '1') {
                one_counts[i] += 1;
            }
        }
    }

    var gamma_string: [sample_length]u8 = undefined;
    var epsilon_string: [sample_length]u8 = undefined;
    for (one_counts) |count, i| {
        gamma_string[i] = if (count > sample_count / 2) '1' else '0';
        epsilon_string[i] = if (count > sample_count / 2) '0' else '1';
    }

    const gamma = try std.fmt.parseInt(u32, gamma_string[0..], 2);
    const epsilon = try std.fmt.parseInt(u32, epsilon_string[0..], 2);
    const power_consumption = gamma * epsilon;

    std.debug.print("power consumption is {d}\n", .{ power_consumption });
}

fn lifeSupportRating(samples: []const []const u8) !void {
    var candidates_buffer: [64 * sample_count]u8 = undefined;
    var candidates_allocator = std.heap.FixedBufferAllocator.init(candidates_buffer[0..]);
    var candidates = try std.ArrayList([]const u8).initCapacity(candidates_allocator.allocator(), sample_count);

    for (samples) |sample| {
        candidates.appendAssumeCapacity(sample);
    }

    var digit_index: usize = 0;
    while (digit_index < sample_length):(digit_index += 1) {
        var one_count: u32 = 0;
        for (candidates.items) |candidate| {
            if (candidate[digit_index] == '1') {
                one_count += 1;
            }
        }
        const zero_count = candidates.items.len - one_count;
        const needs_one = one_count >= zero_count;

        var i: usize = candidates.items.len - 1;
        while (true) {
            const candidate = candidates.items[i];
            if (needs_one != (candidate[digit_index] == '1')) {
                _ = candidates.swapRemove(i);
            }

            if (i == 0) {
                break;
            }

            i -= 1;
        }

        if (candidates.items.len == 1) {
            break;
        }
        if (candidates.items.len == 0) {
            unreachable;
        }
    }

    const oxygen = try std.fmt.parseInt(u32, candidates.items[0], 2);

    std.debug.print("oxygen is {d}\n", .{ oxygen });
}

