const std = @import("std");

const Range = struct {
    d_begin: usize,
    s_begin: usize,
    size: usize,
};

fn get_value(val: usize, ranges: std.ArrayList(Range)) usize {
    for (ranges.items) |r| {
        //std.debug.print("{any} {}\n", .{ r, val });
        if (val >= r.s_begin and val < r.s_begin + r.size) {
            return r.d_begin + val - r.s_begin;
        }
    }
    //std.debug.print("\n", .{});
    return val;
}

fn get_dist(arr_ranges: std.ArrayList(std.ArrayList(Range)), val: usize) usize {
    var x = val;
    for (arr_ranges.items) |ranges| {
        x = get_value(x, ranges);
    }
    return x;
}

fn get_ranges(it: *std.mem.SplitIterator(u8, std.mem.DelimiterType.sequence), arr: *std.ArrayList(Range)) !void {
    const rest = it.*.next().?;
    var it_2 = std.mem.split(u8, rest, "\n");
    _ = it_2.next();
    while (it_2.next()) |line| {
        var it_3 = std.mem.split(u8, line, " ");
        const d_begin = try std.fmt.parseInt(usize, it_3.next().?, 10);
        const s_begin = try std.fmt.parseInt(usize, it_3.next().?, 10);
        const size = try std.fmt.parseInt(usize, it_3.next().?, 10);
        try arr.append(Range{ .d_begin = d_begin, .s_begin = s_begin, .size = size });
    }
}

pub fn main() !void {
    const fileName = "first.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var seed_to_soil = std.ArrayList(Range).init(allocator);
    var soil_to_fertilizer = std.ArrayList(Range).init(allocator);
    var fertilizer_to_water = std.ArrayList(Range).init(allocator);
    var water_to_light = std.ArrayList(Range).init(allocator);
    var light_to_temperature = std.ArrayList(Range).init(allocator);
    var temperature_to_humidity = std.ArrayList(Range).init(allocator);
    var humidity_to_location = std.ArrayList(Range).init(allocator);
    var all_in_one = std.ArrayList(std.ArrayList(Range)).init(allocator);

    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_buf);
    defer file.close();
    var it = std.mem.split(u8, read_buf, "\n\n");
    const line_idx: usize = 0;
    _ = line_idx;
    const seeds = it.next().?;
    var it_2 = std.mem.split(u8, seeds, ":");
    _ = it_2.next().?;
    const nums = it_2.next().?;
    _ = nums;
    try get_ranges(&it, &seed_to_soil);
    try get_ranges(&it, &soil_to_fertilizer);
    try get_ranges(&it, &fertilizer_to_water);
    try get_ranges(&it, &water_to_light);
    try get_ranges(&it, &light_to_temperature);
    try get_ranges(&it, &temperature_to_humidity);
    try get_ranges(&it, &humidity_to_location);
    try all_in_one.append(seed_to_soil);
    try all_in_one.append(soil_to_fertilizer);
    try all_in_one.append(fertilizer_to_water);
    try all_in_one.append(water_to_light);
    try all_in_one.append(light_to_temperature);
    try all_in_one.append(temperature_to_humidity);
    try all_in_one.append(humidity_to_location);

    var it_num = std.mem.split(u8, seeds, " ");
    var min_dist: usize = std.math.maxInt(usize);
    while (it_num.next()) |num| {
        //std.debug.print("{s}", .{num});
        const n = std.fmt.parseInt(usize, num, 10) catch continue;
        //std.debug.print("{} {}\n", .{ get_dist(all_in_one, n), n });
        min_dist = @min(min_dist, get_dist(all_in_one, n));
    }

    // while (it.next()) |line| : (line_idx += 1) {
    //     std.debug.print("{s}\n\n", .{line});

    // }
    std.debug.print("{}\n", .{min_dist});
}
