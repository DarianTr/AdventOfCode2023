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

fn get_distance(p1: Point, p2: Point, pref_x: std.ArrayList(usize), pref_y: std.ArrayList(usize)) usize {
    const x = pref_x.items[@max(p1.x, p2.x)] - pref_x.items[@min(p1.x, p2.x)];
    const y = pref_y.items[@max(p1.y, p2.y)] - pref_y.items[@min(p1.y, p2.y)];
    return x + y;
}

// fn get_distance(p1: Point, p2: Point, xs: std.AutoHashMap(usize, void), ys: std.AutoHashMap(usize, void)) usize {
//     const exp = 2;
//     var x_dif: usize = 0;
//     for (@min(p1.x, p2.x) + 1..@max(p1.x, p2.x) + 1) |x| {
//         if (xs.contains(x)) {
//             x_dif += exp;
//         } else {
//             x_dif += 1;
//         }
//     }
//     var y_dif: usize = 0;
//     for (@min(p1.y, p2.y) + 1..@max(p1.y, p2.y) + 1) |y| {
//         if (ys.contains(y)) {
//             y_dif += exp;
//         } else {
//             y_dif += 1;
//         }
//     }
//     const dist = y_dif + x_dif;
//     return dist;
// }

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
    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var input = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var line_it = std.mem.split(u8, read_buf, "\n");
    defer allocator.free(read_buf);
    defer file.close();
    const empty_xs = std.AutoHashMap(usize, void).init(allocator);
    _ = empty_xs;
    var empty_ys = std.AutoHashMap(usize, void).init(allocator);
    var prefsum_x = std.ArrayList(usize).init(allocator);
    var prefsum_y = std.ArrayList(usize).init(allocator);
    try prefsum_y.append(0);
    try prefsum_x.append(0);
    while (line_it.next()) |line| {
        var line_arr = std.ArrayList(u8).init(allocator);
        for (0..line.len) |i| {
            try line_arr.append(line[i]);
        }
        try input.append(line_arr);
    }
    const exp = 1_000_000;
    for (0..input.items.len) |i| {
        if (empty_row(input, i)) {
            try prefsum_y.append(prefsum_y.getLast() + exp);

            try empty_ys.put(i, {});
        } else {
            try prefsum_y.append(prefsum_y.getLast() + 1);
        }
    }
    for (0..input.getLast().items.len) |i| {
        if (empty_col(input, i)) {
            try prefsum_x.append(prefsum_x.getLast() + exp);

            try empty_ys.put(i, {});
        } else {
            try prefsum_x.append(prefsum_x.getLast() + 1);
        }
    }
    const points = try get_points(input);
    var total: usize = 0;
    for (0..points.items.len) |outer| {
        for (outer..points.items.len) |j| {
            const dist = get_distance(points.items[outer], points.items[j], prefsum_x, prefsum_y);
            total += dist;
        }
    }
    std.debug.print("{}\n", .{total});
}
