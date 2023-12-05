const std = @import("std");

const Range = struct {
    d_begin: usize,
    s_begin: usize,
    size: usize,
};

const RangeWithoutMapping = struct {
    start: usize,
    size: usize,
};

fn cmp(context: void, a: Range, b: Range) bool {
    _ = context;
    return a.s_begin < b.s_begin;
}

fn make_rwm(input: RangeWithoutMapping, output: *std.ArrayList(RangeWithoutMapping), ranges: std.ArrayList(Range)) !void {
    var cur = input.start;
    const max = input.start + input.size;
    //std.debug.print("{} ", .{cur});
    for (ranges.items) |r| {
        // std.debug.print("{} {} {}\n", .{ cur, r.s_begin, r.size });
        // std.debug.print("{any}\n", .{r});
        if (cur >= r.s_begin) {
            if (cur < r.s_begin + r.size) {
                if (max >= r.s_begin + r.size) {
                    try output.append(RangeWithoutMapping{
                        .start = cur + r.d_begin - r.s_begin,
                        .size = r.s_begin + r.size - cur,
                    });
                    cur = r.s_begin + r.size;
                } else {
                    try output.append(RangeWithoutMapping{
                        .start = cur + r.d_begin - r.s_begin,
                        .size = input.size - (cur - input.start),
                    });
                    cur = input.size + input.start;
                    break;
                }
            }
        } else {
            if (max < r.s_begin) {
                try output.append(RangeWithoutMapping{ .start = cur, .size = input.size - (cur - input.start) });
                cur = input.size + input.start;
                break;
            }
        }
    }
    if (cur < input.size + input.start) {
        try output.append(RangeWithoutMapping{ .start = cur, .size = input.size - (cur - input.start) });
    }

    // std.debug.print("\n", .{});
}

fn get_dist(input: RangeWithoutMapping, ranges: std.ArrayList(std.ArrayList(Range))) !usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var working_ranges = std.ArrayList(RangeWithoutMapping).init(allocator);
    //defer allocator.free(working_ranges);
    try working_ranges.append(input);
    var next_working_ranges = std.ArrayList(RangeWithoutMapping).init(allocator);
    //defer allocator.free(next_working_ranges);

    for (ranges.items) |rs| {
        for (working_ranges.items) |r| {
            try make_rwm(r, &next_working_ranges, rs);
        }
        //std.debug.print("{}\n", .{next_working_ranges.items.len});
        working_ranges = next_working_ranges;
        next_working_ranges = std.ArrayList(RangeWithoutMapping).init(allocator);
    }

    var min_dist: usize = std.math.maxInt(usize);
    for (working_ranges.items) |r| {
        min_dist = @min(min_dist, r.start);
    }
    return min_dist;
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
    const fileName = "second.txt";
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
    std.mem.sort(Range, seed_to_soil.items, {}, cmp);
    try get_ranges(&it, &soil_to_fertilizer);
    std.mem.sort(Range, soil_to_fertilizer.items, {}, cmp);
    try get_ranges(&it, &fertilizer_to_water);
    std.mem.sort(Range, fertilizer_to_water.items, {}, cmp);
    try get_ranges(&it, &water_to_light);
    std.mem.sort(Range, water_to_light.items, {}, cmp);
    try get_ranges(&it, &light_to_temperature);
    std.mem.sort(Range, light_to_temperature.items, {}, cmp);
    try get_ranges(&it, &temperature_to_humidity);
    std.mem.sort(Range, temperature_to_humidity.items, {}, cmp);
    try get_ranges(&it, &humidity_to_location);
    std.mem.sort(Range, humidity_to_location.items, {}, cmp);
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
        const n = std.fmt.parseInt(usize, num, 10) catch continue;
        const size = std.fmt.parseInt(usize, it_num.next().?, 10) catch continue;
        min_dist = @min(min_dist, try get_dist(RangeWithoutMapping{ .start = n, .size = size }, all_in_one));
    }
    std.debug.print("{}\n", .{min_dist});
}
