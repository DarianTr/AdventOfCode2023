const std = @import("std");

fn contains(arr: std.ArrayList(usize), n: usize) bool {
    for (arr.items) |num| {
        if (num == n) return true;
    }
    return false;
}

pub fn main() !void {
    const fileName = "first.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    // var input_arr = std.ArrayList([]const u8).init(allocator);
    defer allocator.free(read_buf);
    // defer allocator.free(input_arr);
    // defer allocator.free(list_of_numbers);
    defer file.close();
    var it = std.mem.split(u8, read_buf, "\n");
    var line_idx: usize = 0;
    var total: usize = 0;
    while (it.next()) |line| : (line_idx += 1) {
        var it_2 = std.mem.tokenizeAny(u8, line, ":|");
        _ = it_2.next().?;
        const winning_numbers = it_2.next().?;
        const numbers = it_2.next().?;
        var it_3 = std.mem.split(u8, winning_numbers, " ");
        var it_4 = std.mem.split(u8, numbers, " ");
        const alloc = arena.allocator();
        var winning = std.ArrayList(usize).init(alloc);
        var nums = std.ArrayList(usize).init(alloc);
        while (it_3.next()) |num| {
            if (num.len == 0) continue;
            try winning.append(try std.fmt.parseInt(usize, num, 10));
        }
        while (it_4.next()) |num| {
            if (num.len == 0) continue;
            try nums.append(try std.fmt.parseInt(usize, num, 10));
        }
        var count: usize = 0;
        for (nums.items) |num| {
            if (contains(winning, num)) {
                count += 1;
            }
        }
        if (count > 0) total += std.math.pow(usize, 2, count - 1);
        //std.debug.print("{}\n", .{count});
    }
    std.debug.print("{}\n", .{total});
}
