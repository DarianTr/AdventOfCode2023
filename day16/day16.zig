const std = @import("std");
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var lookup = std.AutoArrayHashMap(Direction, [2]i8).init(allocator);

const map_size: usize = 110;

pub const Direction = enum(u8) {
    North = 0,
    East = 1,
    South = 2,
    West = 3,
};

const BeamPosition = struct {
    x: usize,
    y: usize,
    facing: Direction,

    fn get_next(self: *const BeamPosition, input: std.ArrayList([]const u8)) ?BeamPosition {
        const res = lookup.get(self.facing).?;
        if ((self.x == 0 and res[0] < 0) or (self.y == 0 and res[1] < 0) or (add(self.x, res[0]) >= input.getLast().len) or (add(self.y, res[1]) >= input.items.len)) {
            return null;
        } else {
            return BeamPosition{ .x = add(self.x, res[0]), .y = add(self.y, res[1]), .facing = self.facing };
        }
    }
};

fn add(a: usize, b: i8) usize {
    const a_as_u32: u32 = @truncate(a);
    const a_as_i32: i32 = @bitCast(a_as_u32);
    const sum: i32 = a_as_i32 + @as(i32, b);
    const sum_as_u32: u32 = @bitCast(sum);
    return @as(usize, sum_as_u32);
}

fn bfs(input: std.ArrayList([]const u8), start: BeamPosition, visited: *[map_size][map_size][4]bool) !void {
    var working = std.ArrayList(BeamPosition).init(allocator);
    try working.append(start);
    while (working.items.len > 0) {
        const cur = working.items[0];
        _ = working.orderedRemove(0);
        if (visited[cur.x][cur.y][@intFromEnum(cur.facing)]) continue;
        visited[cur.x][cur.y][@intFromEnum(cur.facing)] = true;

        if (input.items[cur.y][cur.x] == '.') {
            const next = cur.get_next(input);
            if (next) |n| {
                try working.append(n);
            }
        }
        if (input.items[cur.y][cur.x] == '/') {
            var i = @intFromEnum(cur.facing);
            if (i % 2 != 0) {
                i += 3;
            } else {
                i += 1;
            }
            i %= 4;

            const next = (BeamPosition{ .x = cur.x, .y = cur.y, .facing = @enumFromInt(i) }).get_next(input);
            if (next) |n| {
                try working.append(n);
            }
        }
        if (input.items[cur.y][cur.x] == '\\') {
            var i = @intFromEnum(cur.facing);
            if (i % 2 == 0) {
                i += 3;
            } else {
                i += 1;
            }
            i %= 4;
            const next = (BeamPosition{ .x = cur.x, .y = cur.y, .facing = @enumFromInt(i) }).get_next(input);
            if (next) |n| {
                try working.append(n);
            }
        }
        if (input.items[cur.y][cur.x] == '-') {
            if (cur.facing == Direction.East or cur.facing == Direction.West) {
                const next = cur.get_next(input);
                if (next) |n| {
                    try working.append(n);
                }
            } else {
                const facing1: Direction = @enumFromInt((@intFromEnum(cur.facing) + 1) % 4);
                const facing2: Direction = @enumFromInt((@intFromEnum(cur.facing) + 3) % 4);
                const next1 = (BeamPosition{ .x = cur.x, .y = cur.y, .facing = facing1 }).get_next(input);
                const next2 = (BeamPosition{ .x = cur.x, .y = cur.y, .facing = facing2 }).get_next(input);
                if (next1) |n| {
                    try working.append(n);
                }
                if (next2) |n| {
                    try working.append(n);
                }
            }
        }
        if (input.items[cur.y][cur.x] == '|') {
            if (cur.facing == Direction.North or cur.facing == Direction.South) {
                const next = cur.get_next(input);
                if (next) |n| {
                    try working.append(n);
                }
            } else {
                const facing1: Direction = @enumFromInt((@intFromEnum(cur.facing) + 1) % 4);
                const facing2: Direction = @enumFromInt((@intFromEnum(cur.facing) + 3) % 4);
                const next1 = (BeamPosition{ .x = cur.x, .y = cur.y, .facing = facing1 }).get_next(input);
                const next2 = (BeamPosition{ .x = cur.x, .y = cur.y, .facing = facing2 }).get_next(input);
                if (next1) |n| {
                    try working.append(n);
                }
                if (next2) |n| {
                    try working.append(n);
                }
            }
        }
    }
}

pub fn main() !void {
    try lookup.put(Direction.North, [2]i8{ 0, -1 });
    try lookup.put(Direction.South, [2]i8{ 0, 1 });
    try lookup.put(Direction.East, [2]i8{ 1, 0 });
    try lookup.put(Direction.West, [2]i8{ -1, 0 });

    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var input = std.ArrayList([]const u8).init(allocator);
    var split = std.mem.split(u8, read_buf, "\n");
    while (split.next()) |l| {
        try input.append(l);
    }
    var res: usize = 0;

    var direction_deltas = [_][2]i128{ [_]i128{ -1, 0 }, [_]i128{ 0, -1 }, [_]i128{ 1, 0 }, [_]i128{ 0, 1 } };
    var start_x: i128 = map_size - 1;
    var start_y: i128 = map_size - 1;
    const fields = std.meta.fields(Direction);

    inline for (fields) |facing| {
        for (0..map_size) |k| {
            var visited: [map_size][map_size][4]bool = undefined;
            try bfs(input, BeamPosition{ .x = @intCast(start_x), .y = @intCast(start_y), .facing = @field(Direction, facing.name) }, &visited);
            var counter: usize = 0;
            for (0..map_size) |i| {
                for (0..map_size) |j| {
                    for (visited[i][j]) |a| {
                        if (a == true) {
                            counter += 1;
                            break;
                        }
                    }
                }
            }
            res = @max(res, counter);

            if (k < map_size - 1) {
                start_x += direction_deltas[@intFromEnum(@field(Direction, facing.name))][0];
                start_y += direction_deltas[@intFromEnum(@field(Direction, facing.name))][1];
            }
        }
    }
    std.debug.print("{}\n", .{res});
}
