const std = @import("std");
const real_input = @embedFile("day-15_real-input");
const test_input = @embedFile("day-15_test-input");

pub fn main() !void {
    std.debug.print("--- Day 15 ---\n", .{});
    const result = try execute(real_input);
    std.debug.print("lowest total risk is {}\n", .{ result });
}

fn execute(input: []const u8) !u32 {
    var alloc_buffer: [1024 * 1024]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(alloc_buffer[0..]);

    var map_list = std.ArrayList(Pos).init(alloc.allocator());
    defer map_list.deinit();

    var edge_length: usize = undefined;

    var input_it = std.mem.tokenize(u8, input, "\r\n");
    while (input_it.next()) |line| {
        if (line.len == 0) continue;

        edge_length = line.len;

        for (line) |pos_cost_char| {
            const cost = pos_cost_char - '0';
            const pos = Pos {
                .individual_cost = cost,
            };

            try map_list.append(pos);
        }
    }

    var map = map_list.items;
    map[0].lowest_cost = 0;

    var anything_changed = true;
    while (anything_changed) {
        anything_changed = false;

        for (map) |pos, i| {
            const x = i % edge_length;
            const y = i / edge_length;

            var neighbor_indices = std.ArrayList(usize).init(alloc.allocator());
            defer neighbor_indices.deinit();

            if (x > 0) {
                try neighbor_indices.append(i - 1);
            }
            if (x < edge_length - 1) {
                try neighbor_indices.append(i + 1);
            }
            if (y > 0) {
                try neighbor_indices.append(i - edge_length);
            }
            if (y < edge_length - 1) {
                try neighbor_indices.append(i + edge_length);
            }

            for (neighbor_indices.items) |neighbor_i| {
                const neighbor = &map[neighbor_i];
                const potential_cost = pos.lowest_cost + neighbor.individual_cost;

                if (potential_cost < neighbor.lowest_cost) {
                    neighbor.lowest_cost = potential_cost;
                    anything_changed = true;
                }
            }
        }
    }

    return map[map.len - 1].lowest_cost;
}

const Pos = struct {
    individual_cost: u32,
    lowest_cost: u32 = std.math.maxInt(u32),
};

test "test-input" {
    const expected: u32 = 40;
    const result = try execute(test_input);
    try std.testing.expectEqual(expected, result);
}

fn assert(condition: bool, message: []const u8) void {
    if (!condition) {
        @panic(message);
    }
}
