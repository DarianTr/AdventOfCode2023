const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Dir = enum(usize) {
    North,
    East,
    South,
    West,
};

const Point = struct {
    color: []const u8,
    len: i64,
    dir: Dir,
};

var direction_deltas = [_][2]i64{ [_]i64{ 0, -1 }, [_]i64{ 1, 0 }, [_]i64{ 0, 1 }, [_]i64{ -1, 0 } };

fn get_area(instruction: std.ArrayList(Point)) i64 {
    var area: i64 = 0;
    var start_x: i64 = 0;
    var start_y: i64 = 0;
    var u: i64 = 0;
    for (instruction.items) |i| {
        u += i.len;
        const next_x = start_x + i.len * direction_deltas[@intFromEnum(i.dir)][0];
        const next_y = start_y + i.len * direction_deltas[@intFromEnum(i.dir)][1];
        area += @divExact((start_x - next_x) * (start_y + next_y), 2);
        start_x = next_x;
        start_y = next_y;
    }
    const a = area + 1 - @divExact(u, 2);
    return a + u;
}

fn to_dir(a: u8) Dir {
    if (a == 'R') {
        return Dir.East;
    } else if (a == 'L') {
        return Dir.West;
    } else if (a == 'U') {
        return Dir.North;
    } else {
        return Dir.South;
    }
}

pub fn main() !void {
    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var instructions = std.ArrayList(Point).init(allocator);
    var it = std.mem.split(u8, read_buf, "\n");
    while (it.next()) |l| {
        var split_line = std.mem.split(u8, l, " ");
        const dir = to_dir(split_line.next().?[0]);
        const len = split_line.next().?[0] - '0';
        const color = split_line.next().?;
        //std.debug.print("{} {?}\n", .{ len, dir });
        try instructions.append(Point{
            .color = color,
            .len = len,
            .dir = dir,
        });
    }
    const res = get_area(instructions);
    std.debug.print("{}\n", .{res});
}
