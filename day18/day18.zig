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
    len: usize,
    dir: Dir,
};

const Edge = struct {
    x1: i64,
    y1: i64,
    x2: i64,
    y2: i64,
};

var direction_deltas = [_][2]i64{ [_]i64{ 0, -1 }, [_]i64{ 1, 0 }, [_]i64{ 0, 1 }, [_]i64{ -1, 0 } };

fn to_dir(a: u8) Dir {
    if (a == 'R') {
        return Dir.East;
    } else if (a == 'L') {
        return Dir.West;
    } else if (a == 'U') {
        return Dir.North;
    } else if (a == 'D') {
        return Dir.South;
    } else {
        unreachable;
    }
}

fn det(x1: i64, y1: i64, x2: i64, y2: i64) i64 {
    return x1 * y2 - (x2 * y1);
}

fn area(i: std.ArrayList(Point), s: i64) i64 {
    _ = s;
    var a: i64 = 0;
    var start_x: i64 = 0;
    var start_y: i64 = 0;
    var u: i64 = 1;
    var c: i64 = 0;
    for (i.items) |in| {
        var next_x = start_x;
        var next_y = start_y;
        const l: i64 = @intCast(in.len);
        next_x += l * direction_deltas[@intFromEnum(in.dir)][0];
        next_y += l * direction_deltas[@intFromEnum(in.dir)][1];
        a += det(start_x, start_y, next_x, next_y);
        u += l;
        c += 1;
        start_x = next_x;
        start_y = next_y;
    }
    a += det(start_x, start_y, 0, 0);
    const ar = @divFloor(a, 2);
    const u_div = @divFloor(u, 2);
    const inside = ar - u_div;
    _ = inside;
    std.debug.print("{} {} {}\n", .{ ar * 2, u, c });
    return ar + @divFloor(u, 2) + 1;
}

fn count(i: std.ArrayList(Point)) !i64 {
    var res = std.AutoHashMap(Edge, void).init(allocator);
    var start_x: i64 = 0;
    var start_y: i64 = 0;
    for (i.items) |in| {
        var next_x = start_x;
        var next_y = start_y;
        for (0..in.len) |_| {
            next_x += direction_deltas[@intFromEnum(in.dir)][0];
            next_y += direction_deltas[@intFromEnum(in.dir)][1];
            try res.put(Edge{ .x1 = next_x - direction_deltas[@intFromEnum(in.dir)][0], .y1 = next_y - direction_deltas[@intFromEnum(in.dir)][1], .x2 = next_x, .y2 = next_y }, {});
        }
        start_x = next_x;
        start_y = next_y;
    }
    return @intCast(res.count());
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
        const len = try std.fmt.parseInt(usize, split_line.next().?, 10);
        const color = split_line.next().?;
        try instructions.append(Point{
            .color = color,
            .len = len,
            .dir = dir,
        });
    }
    const c = try count(instructions);
    const res = area(instructions, c);
    std.debug.print("{}\n", .{res});
}
