const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

pub fn main() !void {
    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var it = std.mem.tokenizeAny(u8, read_buf, ",");
    var total: usize = 0;
    while (it.next()) |s| {
        var hash: usize = 0;
        for (s) |i| {
            hash += i;
            hash *= 17;
            hash %= 256;
        }
        total += hash;
    }
    std.debug.print("{}\n", .{total});
}
