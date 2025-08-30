const c = @cImport({
    @cInclude("schrift/schrift.h");
});

pub const SFT = c.SFT;
pub const Font = c.SFT_Font;
pub const UChar = c.SFT_UChar;
pub const Glyph = c.SFT_Glyph;
pub const LMetrics = c.SFT_LMetrics;
pub const GMetrics = c.SFT_GMetrics;
pub const Kerning = c.SFT_Kerning;
pub const Image = c.SFT_Image;

pub fn version() [*:0]const u8 {
    return @ptrCast(c.sft_version());
}

pub fn loadMem(mem: *const anyopaque, size: usize) !*Font {
    return c.sft_loadmem(mem, size) orelse return error.LoadError;
}

pub fn loadFile(filename: [:0]const u8) !*Font {
    return c.sft_loadfile(filename) orelse return error.LoadError;
}

pub fn freeFont(font: *c.SFT_Font) void {
    return c.sft_freefont(font);
}

pub fn lmetrics(sft: *const SFT) !LMetrics {
    var metrics: LMetrics = .{};
    const result: i32 = @intCast(c.sft_lmetrics(sft, &metrics));
    if (result != 0) return error.ParseError;
    return metrics;
}

pub fn lookup(sft: *const SFT, codepoint: UChar) !Glyph {
    var glyph: Glyph = undefined;
    const result: i32 = @intCast(c.sft_lookup(sft, codepoint, &glyph));
    if (result != 0) return error.ParseError;
    return glyph;
}

pub fn gmetrics(sft: *const SFT, glyph: Glyph) !GMetrics {
    var metrics: GMetrics = undefined;
    const result: i32 = @intCast(c.sft_gmetrics(sft, glyph, &metrics));
    if (result != 0) return error.ParseError;
    return metrics;
}

pub fn kerning(sft: *const SFT, left: Glyph, right: Glyph) !Kerning {
    var _kerning: Kerning = undefined;
    const result: i32 = @intCast(c.sft_kerning(sft, left, right, &_kerning));
    if (result != 0) return error.ParseError;
    return _kerning;
}

pub fn render(sft: *const SFT, glyph: Glyph, image: Image) !void {
    const result: i32 = @intCast(c.sft_render(sft, glyph, image));
    if (result != 0) return error.ParseError;
}
