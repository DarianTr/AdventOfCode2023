const std = @import("std");

pub fn main() !void {
    const fileName = "second.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_buf);
    defer file.close();
    var total: u32 = 0;
    var it = std.mem.split(u8, read_buf, "\n");
    var id: u32 = 1;
    while (it.next()) |line| : (id += 1) {
        var second_it = std.mem.split(u8, line, ":");
        var right_side: []const u8 = undefined;
        while (second_it.next()) |side| {
            right_side = side;
        }
        var third_it = std.mem.split(u8, right_side, ";");
        var green_max: u32 = 0;
        var red_max: u32 = 0;
        var blue_max: u32 = 0;
        while (third_it.next()) |group| {
            var green: u32 = 0;
            var blue: u32 = 0;
            var red: u32 = 0;
            var fourth_it = std.mem.split(u8, group, ",");
            while (fourth_it.next()) |info| {
                var fifth_it = std.mem.split(u8, info, " ");
                _ = fifth_it.next().?;
                const amount_s = fifth_it.next().?;
                // std.debug.print("hey {s}", .{amount_s});
                const amount: u32 = try std.fmt.parseInt(u32, amount_s, 10);
                const color: []const u8 = fifth_it.next().?;
                if (std.mem.eql(u8, "blue", color)) {
                    blue += amount;
                } else if (std.mem.eql(u8, "red", color)) {
                    red += amount;
                } else if (std.mem.eql(u8, "green", color)) {
                    green += amount;
                }
            }
            if (blue > blue_max) blue_max = blue;
            if (red > red_max) red_max = red;
            if (green > green_max) green_max = green;
        }
        // if (blue_max <= 14 and red_max <= 12 and green_max <= 13) {
        //     total += id;
        // }
        total += red_max * blue_max * green_max;
        // const alloc = std.heap.page_allocator;
        // var arr = std.ArrayList([]u8).init(alloc);
        // while (third_it.next()) |group| {
        //     arr.append(group) catch unreachable;
        // }
    }
    std.debug.print("{}\n", .{total});
}
