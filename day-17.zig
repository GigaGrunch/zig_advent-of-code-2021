const std = @import("std");

pub fn main() !void {
    std.debug.print("--- Day 17 ---\n", .{});
}

fn simulateProbe(target: Rect, initial_velocity: Vector) struct{ highest_y: i32, is_hit: bool, } {
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

test "simulateProbe" {
    const input_area = Rect { .min_x = 20, .max_x = 30, .min_y = -10, .max_y = -5 };
    const initial_velocity = Vector { .x = 6, .y = 9 };
    const expected_hit = true;
    const expected_y: i32 = 45;
    const result = simulateProbe(input_area, initial_velocity);
    try std.testing.expectEqual(expected_hit, result.is_hit);
    try std.testing.expectEqual(expected_y, result.highest_y);
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
