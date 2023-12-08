const std = @import("std");

const Next = struct {
    left: []const u8,
    right: []const u8,
};

pub fn is_equal(a: []const u8, b: []const u8) bool {
    for (0..3) |i| {
        if (a[i] != b[i]) return false;
    }
    return true;
}

pub fn main() !void {
    const fileName = "first.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_buf);
    defer file.close();
    var hash_map = std.StringHashMap(Next).init(allocator);
    defer allocator.destroy(&hash_map);

    var it = std.mem.split(u8, read_buf, "\n\n");
    const key = it.next().?;
    const output = try allocator.dupe(u8, key);
    const key_size = key.len;
    std.mem.replaceScalar(u8, output, 'L', 0);
    std.mem.replaceScalar(u8, output, 'R', 1);

    const map = it.next().?;
    var nexts = std.mem.split(u8, map, "\n");
    while (nexts.next()) |next| {
        //std.debug.print("{s}\n", .{next});
        var it_2 = std.mem.split(u8, next, " = ");
        const start = it_2.next().?;
        const next_steps = it_2.next().?;
        var it_3 = std.mem.tokenizeAny(u8, next_steps, "(), ");
        const left = it_3.next().?;
        const right = it_3.next().?;
        try hash_map.put(start, Next{ .left = left, .right = right });
    }
    var step_count: usize = 0;
    var current_pos: []const u8 = "AAA";
    const last: []const u8 = "ZZZ";
    while (!std.mem.eql(u8, current_pos, last)) : (step_count += 1) {
        const next_step = hash_map.get(current_pos).?;
        if (key[step_count % key_size] == 'L') {
            current_pos = next_step.left;
        } else {
            current_pos = next_step.right;
        }
    }

    std.debug.print("{}\n", .{step_count});
}
