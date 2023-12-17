const std = @import("std");
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Direction = enum(usize) {
    North = 0,
    East,
    South,
    West,
};

const PQContent = struct {
    heat_loss: usize,
    x: usize,
    y: usize,
    straight_count: usize,
    direction: ?Direction,
};

fn lessThan(context: void, a: PQContent, b: PQContent) std.math.Order {
    _ = context;
    if (a.heat_loss > b.heat_loss) {
        return std.math.Order.gt;
    } else if (a.heat_loss == b.heat_loss) {
        return std.math.Order.eq;
    } else {
        return std.math.Order.lt;
    }
}

var direction_deltas = [_][2]i128{ [_]i128{ 0, -1 }, [_]i128{ 1, 0 }, [_]i128{ 0, 1 }, [_]i128{ -1, 0 } };

fn get_neighbors(map: std.ArrayList([]const u8), cur: PQContent, heat_loss: usize) !std.ArrayList(PQContent) {
    var res = std.ArrayList(PQContent).init(allocator);
    var opp: ?Direction = undefined;
    if (cur.direction) |d| {
        opp = @enumFromInt((@intFromEnum(d) + 2) % 4);
    } else {
        opp = null;
    }
    if (cur.direction != null and cur.straight_count < 3) {
        var ix: i128 = @intCast(cur.x);
        var iy: i128 = @intCast(cur.y);
        var x: i128 = ix + direction_deltas[@intFromEnum(cur.direction.?)][0];
        var y: i128 = iy + direction_deltas[@intFromEnum(cur.direction.?)][1];
        if ((x >= 0 and x < map.getLast().len) and (y >= 0 and y < map.items.len)) {
            try res.append(PQContent{
                .x = @intCast(x),
                .y = @intCast(y),
                .direction = cur.direction,
                .heat_loss = map.items[@intCast(y)][@intCast(x)] + heat_loss - '0',
                .straight_count = cur.straight_count + 1,
            });
        }
    } else {
        inline for (std.meta.fields(Direction)) |f| {
            const dir = @field(Direction, f.name);
            if (opp == null or dir != opp.?) {
                var ix: i128 = @intCast(cur.x);
                var iy: i128 = @intCast(cur.y);
                var x: i128 = ix + direction_deltas[@intFromEnum(dir)][0];
                var y: i128 = iy + direction_deltas[@intFromEnum(dir)][1];

                var s_count = cur.straight_count;
                if (cur.direction != null and dir == cur.direction.?) {
                    s_count += 1;
                } else {
                    s_count = 0;
                }
                if (s_count < 10) {
                    if ((x >= 0 and x < map.getLast().len) and (y >= 0 and y < map.items.len)) {
                        try res.append(PQContent{
                            .x = @intCast(x),
                            .y = @intCast(y),
                            .direction = dir,
                            .heat_loss = map.items[@intCast(y)][@intCast(x)] + heat_loss - '0',
                            .straight_count = s_count,
                        });
                    }
                }
            }
        }
    }
    return res;
}

fn dijkstra(map: std.ArrayList([]const u8), start: PQContent) !usize {
    var pq = std.PriorityQueue(PQContent, void, lessThan).init(allocator, {});
    var dist: [141][141][10][4]usize = [_][141][10][4]usize{[_][10][4]usize{[_][4]usize{[_]usize{std.math.maxInt(usize) - 5} ** 4} ** 10} ** 141} ** 141;
    const test_size: usize = 140;
    const y: usize = 140;
    try pq.add(start);
    while (pq.len > 0) {
        const cur = pq.remove();
        if (cur.x == test_size and cur.y == y and cur.straight_count >= 3) {
            return cur.heat_loss;
        }
        if (cur.direction != null and cur.heat_loss >= dist[cur.x][cur.y][cur.straight_count][@intFromEnum(cur.direction.?)]) continue; // and dir_arr[cur.x][cur.y][cur.straight_count][@intFromEnum(cur.direction)]
        if (cur.direction != null) dist[cur.x][cur.y][cur.straight_count][@intFromEnum(cur.direction.?)] = cur.heat_loss;
        for ((try get_neighbors(map, cur, cur.heat_loss)).items) |n| {
            try pq.add(n);
        }
    }
    //return not valid
    std.debug.print("not valid\n", .{});
    return dist[test_size][test_size][0][0];
}

pub fn main() !void {
    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var map = std.ArrayList([]const u8).init(allocator);
    var it = std.mem.split(u8, read_buf, "\n");
    while (it.next()) |l| {
        try map.append(l);
    }
    const res = try dijkstra(map, PQContent{
        .x = 0,
        .y = 0,
        .heat_loss = 0,
        .straight_count = 0,
        .direction = null, //makes a difference now
    });
    std.debug.print("{}\n", .{res});
}
