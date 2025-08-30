pub const bindings = @import("bindings.zig");

pub const UChar = bindings.UChar;
pub const LMetrics = bindings.LMetrics;
pub const Glyph = bindings.Glyph;
pub const GMetrics = bindings.GMetrics;
pub const Kerning = bindings.Kerning;
pub const Image = bindings.Image;

pub var downward_y: c_int = 0;

pub const Font = struct {
    ptr: *bindings.Font,

    pub fn initMem(mem: *const anyopaque, size: usize) !Font {
        return .{
            .ptr = try bindings.loadMem(mem, size),
        };
    }

    pub fn initFile(filename: [:0]const u8) !Font {
        return .{
            .ptr = try bindings.loadFile(filename),
        };
    }

    pub fn deinit(font: Font) void {
        bindings.freeFont(font.ptr);
    }

    pub fn lineMetrics(font: Font, y_scale: f64) !LMetrics {
        return bindings.lmetrics(&.{
            .font = font.ptr,
            .yScale = y_scale,
            .flags = downward_y,
        });
    }

    pub fn lookup(font: Font, codepoint: UChar) !Glyph {
        return bindings.lookup(&.{
            .font = font.ptr,
            .flags = downward_y,
        }, codepoint);
    }

    pub fn glyphMetrics(
        font: Font,
        glyph: Glyph,
        x_scale: f64,
        y_scale: f64,
        x_offset: f64,
        y_offset: f64,
    ) !GMetrics {
        return bindings.gmetrics(&.{
            .font = font.ptr,
            .xScale = x_scale,
            .yScale = y_scale,
            .xOffset = x_offset,
            .yOffset = y_offset,
            .flags = downward_y,
        }, glyph);
    }

    pub fn kerning(font: Font, left: Glyph, right: Glyph, x_scale: f64, y_scale: f64) !Kerning {
        return bindings.kerning(&.{
            .font = font.ptr,
            .xScale = x_scale,
            .yScale = y_scale,
            .flags = downward_y,
        }, left, right);
    }

    pub fn renderGlyph(
        font: Font,
        glyph: Glyph,
        x_scale: f64,
        y_scale: f64,
        x_offset: f64,
        y_offset: f64,
        width: u32,
        height: u32,
        output: [*]u8,
    ) !void {
        const image = Image{
            .width = @intCast(width),
            .height = @intCast(height),
            .pixels = output,
        };
        return bindings.render(&.{
            .font = font.ptr,
            .xScale = x_scale,
            .yScale = y_scale,
            .xOffset = x_offset,
            .yOffset = y_offset,
            .flags = downward_y,
        }, glyph, image);
    }
};

pub fn version() [*:0]const u8 {
    return @ptrCast(bindings.version());
}
