const std = @import("std");
const real_input = @embedFile("day-15_real-input");
const test_input = @embedFile("day-15_test-input");

pub fn main() !void {
    std.debug.print("--- Day 15 ---\n", .{});
    const result = try execute(real_input, true);
    std.debug.print("lowest total risk is {}\n", .{ result });
}

fn execute(input: []const u8, unfold_map: bool) !u32 {
    var alloc_buffer: [2 * 1024 * 1024]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(alloc_buffer[0..]);

    var initial_map = std.ArrayList(Pos).init(alloc.allocator());
    defer initial_map.deinit();

    var initial_edge_length: usize = undefined;

    var input_it = std.mem.tokenize(u8, input, "\r\n");
    while (input_it.next()) |line| {
        if (line.len == 0) continue;

        initial_edge_length = line.len;

        for (line) |pos_cost_char| {
            const cost = @intCast(u4, pos_cost_char - '0');
            const pos = Pos {
                .individual_cost = cost,
            };

            try initial_map.append(pos);
        }
    }

    var map: []Pos = undefined;
    var edge_length: usize = undefined;

    if (unfold_map) {
        edge_length = initial_edge_length * 5;
        var full_map = try std.ArrayList(Pos).initCapacity(alloc.allocator(), edge_length * edge_length);

        var y: usize = 0;
        while (y < edge_length):(y += 1) {
            var x: usize = 0;
            while (x < edge_length):(x += 1) {
                const initial_map_x = x % initial_edge_length;
                const initial_map_y = y % initial_edge_length;
                const initial_map_i = initial_map_y * initial_edge_length + initial_map_x;
                const increment = (x / initial_edge_length) + (y / initial_edge_length);
                var pos = initial_map.items[initial_map_i];
                pos.individual_cost += @intCast(u4, increment);
                while (pos.individual_cost > 9) pos.individual_cost -= 9;
                try full_map.append(pos);
            }
        }

        map = full_map.items;
    }
    else {
        map = initial_map.items;
        edge_length = initial_edge_length;
    }

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

const Pos = packed struct {
    individual_cost: u8,
    lowest_cost: u32 = std.math.maxInt(u32),
};

test "day 1 test" {
    const expected: u32 = 40;
    const result = try execute(test_input, false);
    try std.testing.expectEqual(expected, result);
}

test "day 2 test" {
    const expected: u32 = 315;
    const result = try execute(test_input, true);
    try std.testing.expectEqual(expected, result);
}
