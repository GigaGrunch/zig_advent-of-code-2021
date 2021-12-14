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

    var oxygen_candidates = [_]bool{true} ** sample_count;
    var oxygen_candidates_count: usize = sample_count;
    for (one_counts) |count, digit_index| {
        const needs_one = count > sample_count / 2;

        for (samples) |sample, sample_index| {
            if (! oxygen_candidates[sample_index]) continue;

            if (needs_one != (sample[digit_index] == '1')) {
                oxygen_candidates[sample_index] = false;
                oxygen_candidates_count -= 1;
            }
        }

        if (oxygen_candidates_count <= 1) break;
    }

    const oxygen_index = 
    for (oxygen_candidates) |is_condidate, i| {
        if (is_condidate) break i;
    } else unreachable;

    const oxygen = try std.fmt.parseInt(u32, samples[oxygen_index], 2);

    std.debug.print("oxygen: {d}\n", .{ oxygen });
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

