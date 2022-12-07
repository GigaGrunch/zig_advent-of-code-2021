const std = @import("std");
const test_input = @embedFile("day-19_test-input");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    var scanners = std.ArrayList(Scanner).init(alloc);
    defer scanners.deinit();
    defer for (scanners.items) |scanner| scanner.deinit();
    var current_scanner: *Scanner = undefined;

    var lines_it = std.mem.tokenize(u8, test_input, "\r\n");
    while (lines_it.next()) |line| {
        if (std.mem.eql(u8, line[0..3], "---")) {
            try scanners.append(Scanner.init(alloc));
            current_scanner = &scanners.items[scanners.items.len - 1];
        }
        else {
            var coords_it = std.mem.tokenize(u8, line, ",");
            try current_scanner.append(.{
                try std.fmt.parseInt(i32, coords_it.next().?, 10),
                try std.fmt.parseInt(i32, coords_it.next().?, 10),
                try std.fmt.parseInt(i32, coords_it.next().?, 10),
            });
        }
    }

    for (scanners.items) |scanner_1, s1| {
        for (scanners.items[s1+1..]) |scanner_2, s2| {
            std.debug.print("scanners {d} and {d}\n", .{s1, s2});

            for (scanner_1.items) |origin_1| {
                for (scanner_2.items) |origin_2| {
                    for (scanner_1.items) |_coord_1| {
                        const coord_1 = Coords {
                            _coord_1[0] - origin_1[0],
                            _coord_1[1] - origin_1[1],
                            _coord_1[2] - origin_1[2],
                        };

                        var equal_count: u32 = 0;
                        
                        for (scanner_2.items) |_coord_2| {
                            const coord_2 = Coords {
                                _coord_2[0] - origin_2[0],
                                _coord_2[1] - origin_2[1],
                                _coord_2[2] - origin_2[2],
                            };

                            if (std.mem.eql(i32, &coord_1, &coord_2)) {
                                equal_count += 1;

                                // std.debug.print("( ", .{});
                                // printCoords(_coord_1);
                                // std.debug.print(" - ", .{});
                                // printCoords(origin_1);
                                // std.debug.print(") = (", .{});
                                // printCoords(_coord_2);
                                // std.debug.print(" - ", .{});
                                // printCoords(origin_2);
                                // std.debug.print(")\n", .{});
                            }
                        }

                        if (equal_count >= 12) {
                            std.debug.print("match!\n", .{});
                        }
                    }
                }
            }
        }
    }
}

fn printCoords(coords: Coords) void {
    std.debug.print("{d},{d},{d}", .{coords[0], coords[1], coords[2]});
}

const Coords = [3]i32;
const Scanner = std.ArrayList(Coords);
