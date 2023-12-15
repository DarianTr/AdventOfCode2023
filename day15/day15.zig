const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

fn get_hash(s: []const u8) usize {
    var hash: usize = 0;
    for (s) |i| {
        hash += i;
        hash *= 17;
        hash %= 256;
    }
    return hash;
}

fn eql(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (0..a.len) |i| {
        if (b[i] != a[i]) return false;
    }
    return true;
}

pub fn contains(line: *std.ArrayList([]const u8), key: []const u8, all: []const u8) bool {
    var flag: bool = false;
    for (line.items, 0..) |l, i| {
        if (std.mem.eql(u8, l[0 .. l.len - 2], key)) {
            line.items[i] = all;
            flag = true;
        }
    }
    return flag;
}

pub fn remove(line: *std.ArrayList([]const u8), key: []const u8) !void {
    var i: usize = 0;
    for (line.items) |l| {
        i += 1;
        // std.debug.print("{s} {} {s} {}\n", .{ l, l.len, key, key.len });
        // var copy: [100]u8 = undefined;
        // std.mem.copyBackwards(u8, copy[0..l.len], l);
        // const a = copy[0..key.len];
        if (std.mem.eql(u8, l[0 .. l.len - 2], key)) {
            _ = line.orderedRemove(i - 1);
            i -= 1;
        }
    }
}

pub fn main() !void {
    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var it = std.mem.tokenizeAny(u8, read_buf, ",");
    var boxes: [265]std.ArrayList([]const u8) = undefined;
    for (0..256) |i| {
        boxes[i] = std.ArrayList([]const u8).init(allocator);
    }

    var total: usize = 0;
    while (it.next()) |s| {
        if (s[s.len - 1] == '-') {
            const rest = s[0 .. s.len - 1];
            const box_id = get_hash(rest);
            try remove(&boxes[box_id], rest[0..]);
        } else {
            const rest = s[0 .. s.len - 2];
            const box_id = get_hash(rest);
            if (!contains(&boxes[box_id], rest, s)) {
                try boxes[box_id].append(s);
            }
        }
    }
    for (0..256) |i| {
        for (0..boxes[i].items.len) |j| {
            const box = (i + 1);
            const slot = (j + 1);
            const lens = boxes[i].items[j][boxes[i].items[j].len - 1] - '0';
            const b = box * slot * lens;
            //std.debug.print("b: {} {s}\n", .{ b, boxes[i].items[j] });
            total += b;
        }
    }
    std.debug.print("{}\n", .{total});
}
