const std = @import("std");
const real_input = "target area: x=60..94, y=-171..-136";

pub fn main() !void {
    std.debug.print("--- Day 17 ---\n", .{});

    const target = try parseRect(removePrefix(real_input));
    const result = findHighestAndCount(target);
    std.debug.print("highest achievable Y is {}\n", .{ result.highest_y });
    std.debug.print("total hit count is {}\n", .{ result.count });
}

fn findHighestAndCount(target: Rect) struct { highest_y: i32, count: u32, } {
    const limit: i32 = 1000;

    var highest_y: i32 = std.math.minInt(i32);
    var hit_count: u32 = 0;

    var y: i32 = -limit;
    while (y < limit):(y += 1) {
        var x : i32 = 1;
        while (x < limit):(x += 1) {
            const initial_velocity = Vector { .x = x, .y = y };
            const result = simulateProbe(target, initial_velocity);
            if (result.is_hit) {
                hit_count += 1;

                if (result.highest_y > highest_y) {
                    highest_y = result.highest_y;
                }
            }
        }
    }

    return .{ .highest_y = highest_y, .count = hit_count };
}

test "findHighestAndCount" {
    const input_area = Rect { .min_x = 20, .max_x = 30, .min_y = -10, .max_y = -5 };
    const expected_highest: i32 = 45;
    const expected_count: u32 = 112;
    const result = findHighestAndCount(input_area);
    try std.testing.expectEqual(expected_highest, result.highest_y);
    try std.testing.expectEqual(expected_count, result.count);
}

fn simulateProbe(target: Rect, initial_velocity: Vector) ProbeResult {
    var probe = Probe { .vel = initial_velocity };
    var highest_y: i32 = probe.pos.y;

    var is_hit = while (probe.pos.x <= target.max_x and probe.pos.y >= target.min_y):(probe.step()) {
        highest_y = @maximum(highest_y, probe.pos.y);

        if (probe.pos.x >= target.min_x and
            probe.pos.y <= target.max_y) {
            break true;
        }
    } else false;

    return .{ .highest_y = highest_y, .is_hit = is_hit };
}

const ProbeResult = struct{ 
    highest_y: i32,
    is_hit: bool,
};

test "simulateProbe" {
    const input_area = Rect { .min_x = 20, .max_x = 30, .min_y = -10, .max_y = -5 };

    const test_pairs = [_]struct { initial_velocity: Vector, expected: ProbeResult, } {
        .{ .initial_velocity = .{ .x = 7,  .y = 2  }, .expected = .{ .highest_y = 3,  .is_hit = true  } },
        .{ .initial_velocity = .{ .x = 6,  .y = 3  }, .expected = .{ .highest_y = 6,  .is_hit = true  } },
        .{ .initial_velocity = .{ .x = 9,  .y = 0  }, .expected = .{ .highest_y = 0,  .is_hit = true  } },
        .{ .initial_velocity = .{ .x = 17, .y = -4 }, .expected = .{ .highest_y = 0,  .is_hit = false } },
        .{ .initial_velocity = .{ .x = 6,  .y = 9  }, .expected = .{ .highest_y = 45, .is_hit = true  } },
    };

    for (test_pairs) |pair| {
        const result = simulateProbe(input_area, pair.initial_velocity);
        try std.testing.expectEqual(pair.expected, result);
    }
}

const Probe = struct {
    pos: Vector = .{ .x = 0, .y = 0 },
    vel: Vector,

    fn step(probe: *@This()) void {
        probe.pos.x += probe.vel.x;
        probe.pos.y += probe.vel.y;
        if (probe.vel.x > 0) probe.vel.x -= 1;
        probe.vel.y -= 1;
    }
};

const Vector = struct {
    x: i32,
    y: i32,
};

const Rect = struct {
    min_x: i32,
    max_x: i32,
    min_y: i32,
    max_y: i32,
};

fn parseRect(string: []const u8) !Rect {
    var it = std.mem.tokenize(u8, string, "xy=,. ");
    return Rect {
        .min_x = try nextCoord(&it),
        .max_x = try nextCoord(&it),
        .min_y = try nextCoord(&it),
        .max_y = try nextCoord(&it),
    };
}

fn nextCoord(iterator: anytype) !i32 {
    const string = iterator.next().?;
    return try std.fmt.parseInt(i32, string, 10);
}

test "parseRect" {
    const input = "x=20..30, y=-10..-5";
    const expected = Rect { .min_x = 20, .max_x = 30, .min_y = -10, .max_y = -5 };
    const result = try parseRect(input);
    try std.testing.expectEqual(expected, result);
}

fn removePrefix(string: []const u8) []const u8 {
    const prefix = "target area: ";
    return string[prefix.len..];
}

test "removePrefix" {
    const input = "target area: <this is the stuff>";
    const expected = "<this is the stuff>";
    const result = removePrefix(input);
    try std.testing.expectEqualStrings(expected, result);
}
