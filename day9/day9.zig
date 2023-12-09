const std = @import("std");

fn get_first_element(nums: *std.ArrayList(i64)) !i64 {
    const first_element = nums.items[0];
    var all_zero = true;
    for (0..nums.items.len - 1) |i| {
        nums.items[i] = nums.items[i + 1] - nums.items[i];
        all_zero = all_zero and nums.items[i] == 0;
    }
    try nums.resize(nums.items.len - 1);
    if (all_zero) return first_element;
    return first_element - try get_first_element(nums);
}

fn get_last_element(nums: *std.ArrayList(i64)) !i64 {
    const last_element = nums.getLast();
    var all_zero = true;
    for (0..nums.items.len - 1) |i| {
        nums.items[i] = nums.items[i + 1] - nums.items[i];
        all_zero = all_zero and nums.items[i] == 0;
    }
    try nums.resize(nums.items.len - 1);
    if (all_zero) return last_element;
    return last_element + try get_last_element(nums);
}

fn read(read_buf: []u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var sequences = std.mem.split(u8, read_buf, "\n");
    var total: i64 = 0;
    while (sequences.next()) |seq| {
        var num = std.mem.tokenizeAny(u8, seq, " ");
        var nums = std.ArrayList(i64).init(alloc);
        defer nums.deinit();
        while (num.next()) |n| {
            try nums.append(try std.fmt.parseInt(i64, n, 10));
        }
        total += try get_first_element(&nums);
    }
    std.debug.print("{}\n", .{total});
}

pub fn main() !void {
    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_buf);
    defer file.close();
    try read(read_buf);
}
