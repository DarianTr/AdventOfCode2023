const std = @import("std");

pub fn main() !void {
    const fileName = "first.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_buf);
    defer file.close();

    var total: u32 = 0;

    var it = std.mem.split(u8, read_buf, "\n");
    while (it.next()) |line| {
        var first: u32 = 0;
        var last: u32 = 0;
        var got_first: bool = false;
        for (line) |char| {
            const number: u8 = char;
            if (number >= 48 and number <= 57) {
                if (!got_first) {
                    first = number - 48;
                    got_first = true;
                }
                last = number - 48;
            }
        }
        //std.debug.print("{}\n", .{first});
        total += 10 * first + last;
    }
    std.debug.print("{}\n", .{total});
}
