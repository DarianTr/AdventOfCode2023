const std = @import("std");

fn number_of_ways(time: usize, dist: usize) usize {
    var count: usize = 0;
    for (0..time) |t| {
        const time_left = time - t;
        if (time_left * t > dist) {
            count += 1;
        }
    }
    return count;
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
    var it = std.mem.split(u8, read_buf, "\n");
    const time = it.next().?;
    const dist = it.next().?;
    var it_t = std.mem.split(u8, time, ":");
    _ = it_t.next().?;
    var it_d = std.mem.split(u8, dist, ":");
    _ = it_d.next().?;
    const nums_t = it_t.next().?;
    const nums_d = it_d.next().?;
    var it_nt = std.mem.tokenizeAny(u8, nums_t, " ");
    var it_nd = std.mem.tokenizeAny(u8, nums_d, " ");

    var total: usize = 1;
    while (it_nt.next()) |num_t| {
        //std.debug.print("{s} ", .{num_t});
        const n = std.fmt.parseInt(usize, num_t, 10) catch continue;
        const d = std.fmt.parseInt(usize, it_nd.next().?, 10) catch continue;
        const count = number_of_ways(n, d);
        total *= count;
    }
    std.debug.print("{}\n", .{total});
}
