const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Position = struct {
    x: usize,
    y: usize,
    type: u8,
};

fn accessible_from_below(pos_type: u8) bool {
    return (pos_type == '|' or pos_type == 'F' or pos_type == '7');
}
fn accessible_from_above(pos_type: u8) bool {
    return (pos_type == '|' or pos_type == 'L' or pos_type == 'J');
}
fn accessible_from_left(pos_type: u8) bool {
    return (pos_type == '-' or pos_type == 'J' or pos_type == '7');
}
fn accessible_from_right(pos_type: u8) bool {
    return (pos_type == '-' or pos_type == 'L' or pos_type == 'F');
}

fn get_and_replace_s(map: std.ArrayList([]u8)) [2]Position {
    var pos_s: Position = undefined;
    outer: for (0..map.items.len) |y| {
        for (0..map.getLast().len) |x| {
            const row = map.items[y];
            const pos = row[x];
            //std.debug.print("pos: {c} {} {} {c}\n", .{ pos, x, y, map.items[4][2] });
            if (pos == 'S') {
                map.items[y][x] = 'A';
                // std.debug.print("found: {} {}\n", .{ x, y });
                pos_s = Position{ .x = x, .y = y, .type = undefined };
                break :outer;
            }
        }
    }
    //std.debug.print("{}\n", .{pos_s.y});
    const row_length = map.getLast().len;
    var res: [2]Position = undefined;
    if (pos_s.y > 0 and pos_s.y + 1 < row_length and accessible_from_above(map.items[pos_s.y + 1][pos_s.x]) and accessible_from_below(map.items[pos_s.y - 1][pos_s.x])) { //S == '|'
        res[0] = Position{ .x = pos_s.x, .y = pos_s.y - 1, .type = map.items[pos_s.y - 1][pos_s.x] };
        res[1] = Position{ .x = pos_s.x, .y = pos_s.y + 1, .type = map.items[pos_s.y + 1][pos_s.x] };
    }
    if (pos_s.x > 0 and pos_s.x + 1 < map.items.len and accessible_from_left(map.items[pos_s.y][pos_s.x + 1]) and accessible_from_right(map.items[pos_s.y][pos_s.x - 1])) { //S == '-'
        res[0] = Position{ .x = pos_s.x + 1, .y = pos_s.y, .type = map.items[pos_s.y][pos_s.x + 1] };
        res[1] = Position{ .x = pos_s.x - 1, .y = pos_s.y, .type = map.items[pos_s.y][pos_s.x - 1] };
    }
    if (pos_s.x + 1 < map.items.len and pos_s.y + 1 < row_length and accessible_from_below(map.items[pos_s.y - 1][pos_s.x]) and accessible_from_left(map.items[pos_s.y][pos_s.x + 1])) { //S == 'L'
        res[0] = Position{ .x = pos_s.x, .y = pos_s.y - 1, .type = map.items[pos_s.y - 1][pos_s.x] };
        res[1] = Position{ .x = pos_s.x + 1, .y = pos_s.y, .type = map.items[pos_s.y][pos_s.x + 1] };
    }
    if (pos_s.x > 0 and pos_s.y + 1 < row_length and accessible_from_below(map.items[pos_s.y - 1][pos_s.x]) and accessible_from_right(map.items[pos_s.y][pos_s.x - 1])) { //S == 'J'
        res[0] = Position{ .x = pos_s.x, .y = pos_s.y - 1, .type = map.items[pos_s.y - 1][pos_s.x] };
        res[1] = Position{ .x = pos_s.x - 1, .y = pos_s.y, .type = map.items[pos_s.y][pos_s.x - 1] };
    }
    if (pos_s.y > 0 and pos_s.x > 0 and accessible_from_above(map.items[pos_s.y + 1][pos_s.x]) and accessible_from_right(map.items[pos_s.y][pos_s.x - 1])) { //S == '7'
        res[0] = Position{ .x = pos_s.x, .y = pos_s.y + 1, .type = map.items[pos_s.y + 1][pos_s.x] };
        res[1] = Position{ .x = pos_s.x - 1, .y = pos_s.y, .type = map.items[pos_s.y][pos_s.x - 1] };
    }
    if (pos_s.x + 1 < map.items.len and pos_s.y + 1 < row_length and accessible_from_above(map.items[pos_s.y + 1][pos_s.x]) and accessible_from_left(map.items[pos_s.y][pos_s.x + 1])) { //S == 'F
        //std.debug.print("f\n", .{});
        res[0] = Position{ .x = pos_s.x, .y = pos_s.y + 1, .type = map.items[pos_s.y + 1][pos_s.x] };
        res[1] = Position{ .x = pos_s.x + 1, .y = pos_s.y, .type = map.items[pos_s.y][pos_s.x + 1] };
    }

    if (res[0].x != undefined) map.items[res[0].y][res[0].x] = 'A';
    if (res[1].x != undefined) map.items[res[1].y][res[1].x] = 'A';
    //std.debug.print("{} {} {} {}\n", .{ res[0].x, res[0].y, res[1].x, res[1].y });
    return res;
}

fn get_next_positions(nexts: std.ArrayList(Position), map: std.ArrayList([]u8), lookup: *std.AutoHashMap(Position, void)) !std.ArrayList(Position) {
    var res = std.ArrayList(Position).init(allocator);
    for (nexts.items, 0..) |pos, idx| {
        _ = idx;
        if (pos.y > 0) {
            const top = map.items[pos.y - 1][pos.x];
            if (accessible_from_above(pos.type) and accessible_from_below(top)) {
                const p = Position{ .x = pos.x, .y = pos.y - 1, .type = top };
                if (!lookup.contains(p)) {
                    try res.append(p);
                    try lookup.put(p, {});
                }
            }
        }
        if (pos.y + 1 < map.items.len) {
            const under = map.items[pos.y + 1][pos.x];
            if (accessible_from_above(under) and accessible_from_below(pos.type)) {
                const p = Position{ .x = pos.x, .y = pos.y + 1, .type = under };
                if (!lookup.contains(p)) {
                    try res.append(p);
                    try lookup.put(p, {});
                }
            }
        }
        if (pos.x > 0) {
            const left = map.items[pos.y][pos.x - 1];
            if (accessible_from_left(pos.type) and accessible_from_right(left)) {
                const p = Position{ .x = pos.x - 1, .y = pos.y, .type = left };
                if (!lookup.contains(p)) {
                    try res.append(p);
                    try lookup.put(p, {});
                }
            }
        }
        if (pos.x + 1 < map.items[0].len) {
            const right = map.items[pos.y][pos.x + 1];
            if (accessible_from_right(pos.type) and accessible_from_left(right)) {
                const p = Position{ .x = pos.x + 1, .y = pos.y, .type = right };
                if (!lookup.contains(p)) {
                    try lookup.put(p, {});
                    try res.append(p);
                }
            }
        }
    }
    //print_map(map);
    return res;
}

fn count_loop_size(map: std.ArrayList([]u8), starts: *const [2]Position) !usize {
    var step: usize = 1;
    var nexts = std.ArrayList(Position).init(allocator);
    var visited = std.AutoHashMap(Position, void).init(allocator);
    try nexts.append(starts[0]);
    try nexts.append(starts[1]);
    while (nexts.items.len != 0) : (step += 1) {
        nexts = try get_next_positions(nexts, map, &visited);
        //std.debug.print("{c} {c}\n", .{ nexts[0].type, nexts[1].type });
    }

    return step - 1;
}

fn print_map(map: std.ArrayList([]u8)) void {
    for (map.items) |row| {
        for (row) |item| {
            std.debug.print("{c} ", .{item});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

pub fn main() !void {
    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_buf);
    defer file.close();
    var map = std.ArrayList([]u8).init(allocator);
    var it = std.mem.split(u8, read_buf, "\n");
    var idx: usize = 0;
    var line_copy: [200][200]u8 = undefined;
    while (it.next()) |line| {
        std.mem.copy(u8, line_copy[idx][0..], line);
        try map.append(line_copy[idx][0..line.len]);
        idx += 1;
    }
    const start = get_and_replace_s(map);
    //print_map(map);
    //std.debug.print("{c} {c}\n", .{ start[0].type, start[1].type });
    const res = try count_loop_size(map, &start);
    std.debug.print("{}\n", .{res});
    //try read(read_buf);
}

//Es IST NICHT AUSGESCHLOSSEN, Dass es Pfade vom Kreis weg gibt!
