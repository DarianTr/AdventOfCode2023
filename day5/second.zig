const std = @import("std");

const TransformationRange = struct {
    d_begin: usize,
    s_begin: usize,
    size: usize,
};

const Range = struct {
    start: usize,
    size: usize,
};

fn cmp(context: void, a: TransformationRange, b: TransformationRange) bool {
    _ = context;
    return a.s_begin < b.s_begin;
}

fn make_rwm(input: Range, output: *std.ArrayList(Range), TransformationRanges: std.ArrayList(TransformationRange)) !void {
    var cur = input.start;
    const max = input.start + input.size;
    for (TransformationRanges.items) |r| {
        if (cur >= r.s_begin) {
            if (cur < r.s_begin + r.size) {
                if (max >= r.s_begin + r.size) {
                    try output.append(Range{
                        .start = cur + r.d_begin - r.s_begin,
                        .size = r.s_begin + r.size - cur,
                    });
                    cur = r.s_begin + r.size;
                } else {
                    try output.append(Range{
                        .start = cur + r.d_begin - r.s_begin,
                        .size = input.size - (cur - input.start),
                    });
                    cur = input.size + input.start;
                    break;
                }
            }
        } else {
            if (max < r.s_begin) {
                try output.append(Range{ .start = cur, .size = input.size - (cur - input.start) });
                cur = input.size + input.start;
                break;
            }
        }
    }
    if (cur < input.size + input.start) {
        try output.append(Range{ .start = cur, .size = input.size - (cur - input.start) });
    }
}

fn get_dist(input: Range, transformations: [](std.ArrayList(TransformationRange))) !usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var working_TransformationRanges = std.ArrayList(Range).init(allocator);
    defer allocator.destroy(&working_TransformationRanges);
    var next_working_TransformationRanges = std.ArrayList(Range).init(allocator);

    try working_TransformationRanges.append(input);

    for (transformations) |ts| {
        for (working_TransformationRanges.items) |r| {
            try make_rwm(r, &next_working_TransformationRanges, ts);
        }
        working_TransformationRanges = next_working_TransformationRanges;
        allocator.destroy(&next_working_TransformationRanges);
        next_working_TransformationRanges = std.ArrayList(Range).init(allocator);
    }

    var min_dist: usize = std.math.maxInt(usize);
    for (working_TransformationRanges.items) |r| {
        min_dist = @min(min_dist, r.start);
    }
    return min_dist;
}

fn get_TransformationRanges(it: *std.mem.SplitIterator(u8, std.mem.DelimiterType.sequence), arr: *std.ArrayList(TransformationRange)) !void {
    const rest = it.*.next().?;
    var it_2 = std.mem.split(u8, rest, "\n");
    _ = it_2.next();
    while (it_2.next()) |line| {
        var it_3 = std.mem.split(u8, line, " ");
        const d_begin = try std.fmt.parseInt(usize, it_3.next().?, 10);
        const s_begin = try std.fmt.parseInt(usize, it_3.next().?, 10);
        const size = try std.fmt.parseInt(usize, it_3.next().?, 10);
        try arr.append(TransformationRange{ .d_begin = d_begin, .s_begin = s_begin, .size = size });
    }
}

pub fn main() !void {
    const fileName = "second.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var transformations = [_]std.ArrayList(TransformationRange){std.ArrayList(TransformationRange).init(allocator)} ** 7;

    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_buf);
    defer file.close();

    var it = std.mem.split(u8, read_buf, "\n\n");
    const seeds = it.next().?;
    var it_2 = std.mem.split(u8, seeds, ":");
    _ = it_2.next().?;
    const nums = it_2.next().?;
    _ = nums;
    for (0..7) |transformation_id| {
        try get_TransformationRanges(&it, &transformations[transformation_id]);
        std.mem.sort(TransformationRange, transformations[transformation_id].items, {}, cmp);
    }

    var it_num = std.mem.split(u8, seeds, " ");
    var min_dist: usize = std.math.maxInt(usize);

    while (it_num.next()) |num| {
        const n = std.fmt.parseInt(usize, num, 10) catch continue;
        const size = std.fmt.parseInt(usize, it_num.next().?, 10) catch continue;
        min_dist = @min(min_dist, try get_dist(Range{ .start = n, .size = size }, &transformations));
    }
    std.debug.print("{}\n", .{min_dist});
}
