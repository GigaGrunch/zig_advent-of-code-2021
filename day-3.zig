const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-3_test-input" else "day-3_real-input";
const sample_count = if (use_test_input) 12 else 1000;
const sample_length = if (use_test_input) 5 else 12;

pub fn main() !void {
    std.debug.print("--- Day 3 ---\n", .{});

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
    var oxygen_buffer: [64 * sample_count]u8 = undefined;
    var oxygen_allocator = std.heap.FixedBufferAllocator.init(oxygen_buffer[0..]);
    var oxygen_candidates = try std.ArrayList([]const u8).initCapacity(oxygen_allocator.allocator(), sample_count);

    var co2_buffer: [64 * sample_count]u8 = undefined;
    var co2_allocator = std.heap.FixedBufferAllocator.init(co2_buffer[0..]);
    var co2_candidates = try std.ArrayList([]const u8).initCapacity(co2_allocator.allocator(), sample_count);

    for (samples) |sample| {
        oxygen_candidates.appendAssumeCapacity(sample);
        co2_candidates.appendAssumeCapacity(sample);
    }

    var digit_index: usize = 0;
    while (digit_index < sample_length):(digit_index += 1) {
        if (oxygen_candidates.items.len > 1) {
            var one_count: u32 = 0;
            for (oxygen_candidates.items) |candidate| {
                if (candidate[digit_index] == '1') {
                    one_count += 1;
                }
            }
            const zero_count = oxygen_candidates.items.len - one_count;
            const needs_one = one_count >= zero_count;

            var i: usize = oxygen_candidates.items.len - 1;
            while (true) {
                const candidate = oxygen_candidates.items[i];
                if (needs_one != (candidate[digit_index] == '1')) {
                    _ = oxygen_candidates.swapRemove(i);
                }

                if (i == 0) {
                    break;
                }

                i -= 1;
            }
        }

        if (co2_candidates.items.len > 1) {
            var one_count: u32 = 0;
            for (co2_candidates.items) |candidate| {
                if (candidate[digit_index] == '1') {
                    one_count += 1;
                }
            }
            const zero_count = co2_candidates.items.len - one_count;
            const needs_one = one_count < zero_count;

            var i: usize = co2_candidates.items.len - 1;
            while (true) {
                const candidate = co2_candidates.items[i];
                if (needs_one != (candidate[digit_index] == '1')) {
                    _ = co2_candidates.swapRemove(i);
                }

                if (i == 0) {
                    break;
                }

                i -= 1;
            }
        }

        if (oxygen_candidates.items.len <= 1 and co2_candidates.items.len <= 1) {
            break;
        }
    }

    std.debug.assert(oxygen_candidates.items.len == 1);
    std.debug.assert(co2_candidates.items.len == 1);

    const oxygen = try std.fmt.parseInt(u32, oxygen_candidates.items[0], 2);
    const co2 = try std.fmt.parseInt(u32, co2_candidates.items[0], 2);
    const life_support_rating = oxygen * co2;

    std.debug.print("life support rating is {d}\n", .{ life_support_rating });
}

