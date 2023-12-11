const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Point = struct {
    x: usize,
    y: usize,
};

fn get_points(map: std.ArrayList(std.ArrayList(u8))) !std.ArrayList(Point) {
    var points = std.ArrayList(Point).init(allocator);
    for (0..map.items.len) |y| {
        for (0..map.getLast().items.len) |x| {
            if (map.items[y].items[x] == '#') {
                try points.append(Point{ .x = x, .y = y });
            }
        }
    }
    return points;
}

fn get_distance(p1: Point, p2: Point, xs: std.AutoHashMap(usize, void), ys: std.AutoHashMap(usize, void)) usize {
    const exp = 10;
    var x_dif: usize = 0;
    for (@min(p1.x, p2.x) + 1..@max(p1.x, p2.x) + 1) |x| {
        if (xs.contains(x)) {
            x_dif += exp;
        } else {
            x_dif += 1;
        }
    }
    var y_dif: usize = 0;
    for (@min(p1.y, p2.y) + 1..@max(p1.y, p2.y) + 1) |y| {
        if (ys.contains(y)) {
            y_dif += exp;
        } else {
            y_dif += 1;
        }
    }
    const dist = y_dif + x_dif;
    return dist;
}

fn print_map(map: std.ArrayList(std.ArrayList(u8))) void {
    for (map.items) |row| {
        for (row.items) |item| {
            std.debug.print("{c}", .{item});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

fn insert_row(map: *std.ArrayList(std.ArrayList(u8)), idx: usize) !void {
    var input = std.ArrayList(u8).init(allocator);
    for (0..map.getLast().items.len) |_| {
        try input.append('.');
    }
    try map.insert(idx, input);
}

fn insert_col(map: *std.ArrayList(std.ArrayList(u8)), idx: usize) !void {
    for (0..map.items.len) |i| {
        try map.items[i].insert(idx, '.');
    }
}

fn empty_row(map: std.ArrayList(std.ArrayList(u8)), i: usize) bool {
    for (map.items[i].items) |item| {
        if (item != '.') {
            return false;
        }
    }
    return true;
}

fn empty_col(map: std.ArrayList(std.ArrayList(u8)), i: usize) bool {
    for (0..map.items.len) |idx| {
        if (map.items[idx].items[i] != '.') {
            return false;
        }
    }
    return true;
}

pub fn main() !void {
    const fileName = "test.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var input = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var line_it = std.mem.split(u8, read_buf, "\n");
    defer allocator.free(read_buf);
    defer file.close();
    const empty_xs = std.AutoHashMap(usize, void).init(allocator);
    var empty_ys = std.AutoHashMap(usize, void).init(allocator);
    while (line_it.next()) |line| {
        var line_arr = std.ArrayList(u8).init(allocator);
        for (0..line.len) |i| {
            try line_arr.append(line[i]);
        }
        try input.append(line_arr);
    }
    var i: usize = 0;
    for (input.items) |_| { //watch out input.items.len changes
        if (empty_row(input, i)) {
            // try insert_row(&input, i);
            // i += 1;
            try empty_ys.put(i, {});
        }
        i += 1;
    }
    //std.debug.print("\n", .{});
    i = 0;
    for (0..input.getLast().items.len) |_| {
        if (empty_col(input, i)) {
            // try insert_col(&input, i);
            // i += 1;
            try empty_ys.put(i, {});
        }
        i += 1;
    }
    //print_map(input);
    const points = try get_points(input);
    var total: usize = 0;
    for (0..points.items.len) |outer| {
        for (outer..points.items.len) |j| {
            const dist = get_distance(points.items[outer], points.items[j], empty_xs, empty_ys);
            total += dist;
            //std.debug.print("{} {}\n", .{ points.items.len, dist });
        }
    }
    std.debug.print("{}\n", .{total});
}

//for part two: im array speichern, ob die x koordinate vermillionfacht wird oder nicht.
// das gleiche auch f"ur y koords. Dann bei der dist func uber alle x un y in dem array fuer den bestimmen bereich gehen
// und entweder 1 oder 1M dazuaddiern. Arrays sollten of type bool sein

//1084 statt 1030
