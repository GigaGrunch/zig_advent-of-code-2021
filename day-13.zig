const std = @import("std");

const real_input = @embedFile("day-13_real-input");
const test_input = @embedFile("day-13_test-input");

pub fn main() !void {
    std.debug.print("--- Day 13 ---\n", .{});
    const result = try execute(real_input);
    std.debug.print("there are {} visible dots\n", .{ result });
}

fn execute(input: []const u8) !u32 {
    var buffer: [1024 * 1024]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(buffer[0..]);

    var points = std.ArrayList(Point).init(alloc.allocator());
    var folds = std.ArrayList(Fold).init(alloc.allocator());

    var line_it = std.mem.tokenize(u8, input, "\r\n");
    while (line_it.next()) |line| {
        if (std.mem.startsWith(u8, line, "fold")) {
            var fold_it = std.mem.tokenize(u8, line, " =");
            _ = fold_it.next() orelse unreachable; // fold
            _ = fold_it.next() orelse unreachable; // along
            const direction_string = fold_it.next() orelse unreachable;
            const value_string = fold_it.next() orelse unreachable;
            try folds.append(.{
                .direction = if (direction_string[0] == 'x') .Vertical else .Horizontal,
                .value = try std.fmt.parseInt(u16, value_string, 10),
            });
        }
        else if (line.len > 0) {
            var coords_it = std.mem.tokenize(u8, line, ",");
            const x_string = coords_it.next() orelse unreachable;
            const y_string = coords_it.next() orelse unreachable;
            try points.append(.{
                .x = try std.fmt.parseInt(u16, x_string, 10),
                .y = try std.fmt.parseInt(u16, y_string, 10),
            });
        }
    }

    for (folds.items) |fold| {
        var removed_points = std.ArrayList(usize).init(alloc.allocator());
        var new_points = std.ArrayList(Point).init(alloc.allocator());

        switch (fold.direction) {
            .Vertical => {
                for (points.items) |point, i| {
                    if (point.x < fold.value) continue;
                    const distance = point.x - fold.value;

                    try new_points.append(.{
                        .x = fold.value - distance,
                        .y = point.y,
                    });
                    try removed_points.append(i);
                }
            },
            .Horizontal => {
                for (points.items) |point, i| {
                    if (point.y < fold.value) continue;
                    const distance = point.y - fold.value;

                    try new_points.append(.{
                        .x = point.x,
                        .y = fold.value - distance,
                    });
                    try removed_points.append(i);
                }
            },
        }

        std.mem.reverse(usize, removed_points.items);
        for (removed_points.items) |i| {
            _ = points.swapRemove(i);
        }
        for (new_points.items) |point| {
            if (!contains(points.items, point)) {
                try points.append(point);
            }
        }

        break;
    }

    return @intCast(u32, points.items.len);
}

fn addUnique(points: *std.ArrayList(Point), point: Point) !void {
    if (contains(points.items, point)) return;
    try points.append(point);
}

fn contains(haystack: []Point, needle: Point) bool {
    return for (haystack) |point| {
        if (point.x == needle.x and point.y == needle.y) break true;
    } else false;
}

const Point = struct {
    x: u16,
    y: u16,
};

const Fold = struct {
    direction: enum { Horizontal, Vertical },
    value: u16,
};

test "test-input" {
    const expected: u32 = 17;
    const result = try execute(test_input);
    try std.testing.expectEqual(expected, result);
}
