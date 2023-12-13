const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

fn is_mirror_col(left: usize, right: usize, map: std.ArrayList([]const u8)) usize {
    var diff: usize = 0;
    var l = left;
    var r = right;
    while (l >= 0 and r < map.getLast().len) {
        for (0..map.items.len) |i| {
            if (map.items[i][l] != map.items[i][r]) {
                diff += 1;
            }
        }

        if (l == 0) {
            return diff;
        }

        l -= 1;
        r += 1;
    }
    return diff;
}

fn is_mirror_row(under: usize, above: usize, map: std.ArrayList([]const u8)) usize {
    var u = under;
    var a = above;
    var diff: usize = 0;
    while (a >= 0 and u < map.items.len) {
        for (0..map.getLast().len) |i| {
            if (map.items[a][i] != map.items[u][i]) {
                diff += 1;
            }
        }
        // if (!std.mem.eql(u8, map.items[u], map.items[a])) {
        //     std.debug.print("{} {}\n", .{ a, u });
        //     return false;
        // }

        u += 1;
        if (a == 0) {
            return diff;
        }
        a -= 1;
    }

    return diff;
}

pub fn main() !void {
    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);

    var col: usize = 0;
    var row: usize = 0;

    var it = std.mem.split(u8, read_buf, "\n\n");

    outer: while (it.next()) |b| {
        var map = std.ArrayList([]const u8).init(allocator);
        var it_line = std.mem.split(u8, b, "\n");
        while (it_line.next()) |l| {
            try map.append(l);
        }
        var i: usize = map.items.len - 2;
        while (true) : (i -= 1) {
            if (is_mirror_row(i + 1, i, map) == 1) {
                row += i + 1;
                continue :outer;
            }
            if (i == 0) {
                break;
            }
        }
        i = map.getLast().len - 2;
        while (true) : (i -= 1) {
            if (is_mirror_col(i, i + 1, map) == 1) {
                col += i + 1;
                continue :outer;
            }
            if (i == 0) {
                break;
            }
        }
    }
    std.debug.print("{}\n", .{col + 100 * row});
}
