//! aion config, laid out like aion's src/config.zig, with the @...@ values filled in by replaceVars in modules/programs/aion.nix

const xkb = @import("xkbcommon");
const c = @import("c");
const a = @import("actions.zig");
const menu = @import("menu.zig");

const K = xkb.Keysym;
const MOD = a.LOGO;
const SHIFT = a.SHIFT;
const CTRL = a.CTRL;
const ALT = a.ALT;

// rosé pine, from constants.palette
const base = 0x@base@ff;
const overlay = 0x@overlay@ff;
const muted = 0x@muted@ff;
const subtle = 0x@subtle@ff;
const text = 0x@text@ff;
const love = 0x@love@ff;
const rose = 0x@rose@ff;

const helpers = "@helpers@/bin/";
const power = helpers ++ "aion-power";

pub const sloppyfocus = false;
/// windows asking for attention get focused (switching tag if needed) instead of marked urgent
pub const focus_on_activate = true;
pub const borderpx = 1;
pub const rootcolor = a.color(base);
pub const bordercolor = a.color(muted);
pub const focuscolor = a.color(rose);
pub const urgentcolor = a.color(love);
pub const fullscreen_bg = a.color(0x000000ff);

pub const showbar = true;
pub const fonts = [_][*:0]const u8{"@font@"};
pub const bar_norm: a.Scheme = .{ .fg = subtle, .bg = base };
pub const bar_sel: a.Scheme = .{ .fg = text, .bg = overlay };
/// prints one status line at a time; null reads the status from stdin
pub const status_cmd: ?a.Arg = a.cmd(&.{helpers ++ "aion-status"});

/// apps_cmd prints "Name<TAB>path" lines for mod+d, and launch_cmd plus a path starts one
pub const apps_cmd = a.cmd(&.{helpers ++ "aion-apps"});
pub const launch_cmd = [_][:0]const u8{ helpers ++ "aion-apps", "launch" };

/// mod+x then one of these keys; any other key leaves the mode
pub const session_keys = [_]a.Key{
    .{ .mod = 0, .sym = K.l, .func = a.spawn, .arg = a.cmd(&.{ power, "lock" }) },
    .{ .mod = 0, .sym = K.u, .func = a.spawn, .arg = a.cmd(&.{ power, "suspend" }) },
    .{ .mod = 0, .sym = K.e, .func = a.quit },
    .{ .mod = 0, .sym = K.r, .func = a.spawn, .arg = a.cmd(&.{ power, "reboot" }) },
    .{ .mod = 0, .sym = K.b, .func = a.spawn, .arg = a.cmd(&.{ "foot", "--hold", "sh", "-c", "@rebuildBoot@ && systemctl reboot" }) },
    .{ .mod = 0, .sym = K.s, .func = a.spawn, .arg = a.cmd(&.{ power, "shutdown" }) },
};
pub const session_hint = "l lock  u suspend  e logout  r reboot  b rebuild & reboot  s shutdown";

pub const default_width: f32 = 0.5;
/// size of a window first floated with mod+v, as a fraction of the monitor
pub const float_size = [2]f32{ 0.6, 0.6 };
pub const width_presets = [_]f32{ 1.0 / 3.0, 0.5, 2.0 / 3.0 };
pub const struts: a.Struts = .{ .left = 20, .right = 20 };

pub const tags = [_][]const u8{ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" };

/// from flake.monitors, a set per profile, each shifted so no position is negative
pub const monrules = [_]a.MonitorRule{
@monitorRules@
    .{},
};

/// app_id and title match as substrings; dialogs with a parent float on their own
pub const rules = [_]a.Rule{
    .{ .app_id = "xdg-desktop-portal-gtk", .floating = true },
    .{ .app_id = "org.gtk.FileChooserDialog", .floating = true },
    .{ .title = "Sign in - Google Accounts", .floating = true },
    .{ .title = "Picture-in-Picture", .floating = true },
    .{ .app_id = "steamwebhelper", .floating = true },

    .{ .app_id = "vesktop", .width = 1 },
    .{ .app_id = "gimp", .width = 1 },
    .{ .app_id = "libreoffice", .width = 1 },
    .{ .app_id = "org.qutebrowser.qutebrowser", .width = 1 },
    .{ .app_id = "steam", .title = "Steam", .width = 1 },

    .{ .app_id = "stremio", .fullscreen = true },
    .{ .title = "Steam Big Picture Mode", .fullscreen = true },
};

pub const xkb_rules: xkb.RuleNames = .{
    .rules = null,
    .model = null,
    .layout = "@xkbLayout@",
    .variant = null,
    .options = "@xkbOptions@",
};
pub const repeat_rate = 35;
pub const repeat_delay = 200;

pub const tap_to_click = true;
pub const tap_and_drag = true;
pub const drag_lock = true;
pub const natural_scrolling = true;
pub const disable_while_typing = true;
pub const left_handed = false;
pub const middle_button_emulation = false;
pub const scroll_method = c.LIBINPUT_CONFIG_SCROLL_2FG;
pub const click_method = c.LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
pub const send_events_mode = c.LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
pub const accel_profile = c.LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
pub const accel_speed = 0.0;
pub const button_map = c.LIBINPUT_CONFIG_TAP_MAP_LRM;

/// the same action on a vim key and its arrow
fn both(comptime mod: u32, comptime vim: xkb.Keysym, comptime arrow: xkb.Keysym, comptime func: a.Func, comptime arg: a.Arg) [2]a.Key {
    return .{
        .{ .mod = mod, .sym = vim, .func = func, .arg = arg },
        .{ .mod = mod, .sym = arrow, .func = func, .arg = arg },
    };
}

/// a command that also runs while the session is locked
fn helper(comptime mod: u32, comptime sym: xkb.Keysym, comptime argv: []const [:0]const u8) a.Key {
    return .{ .mod = mod, .sym = sym, .func = a.spawn, .arg = a.cmd(argv), .locked = true };
}

/// mod+1..0 views a tag, +shift moves the window there and follows, +ctrl moves it quietly
fn tagKeys() [3 * tags.len]a.Key {
    var out: [3 * tags.len]a.Key = undefined;
    for (0..tags.len) |i| {
        const sym: K = @fromBackingInt(@backingInt(K.@"0") + @as(u32, @intCast((i + 1) % 10)));
        const arg: a.Arg = .{ .ui = @as(u32, 1) << @intCast(i) };
        out[3 * i ..][0..3].* = .{
            .{ .mod = MOD, .sym = sym, .func = a.view, .arg = arg },
            .{ .mod = MOD | SHIFT, .sym = sym, .func = a.tagfollow, .arg = arg },
            .{ .mod = MOD | CTRL, .sym = sym, .func = a.tag, .arg = arg },
        };
    }
    return out;
}

/// ctrl+alt+f1..f12 switches vt, also while locked
fn vtKeys() [12]a.Key {
    var out: [12]a.Key = undefined;
    for (&out, 1..) |*k, n| {
        k.* = .{ .mod = CTRL | ALT, .sym = @fromBackingInt(@backingInt(K.F1) + @as(u32, @intCast(n - 1))), .func = a.chvt, .arg = .{ .ui = @intCast(n) }, .locked = true };
    }
    return out;
}

pub const keys = [_]a.Key{
    .{ .mod = MOD, .sym = K.t, .func = a.spawn, .arg = a.cmd(&.{"foot"}) },
    .{ .mod = MOD, .sym = K.w, .func = a.spawn, .arg = a.cmd(&.{"qutebrowser"}) },
    .{ .mod = MOD, .sym = K.e, .func = a.spawn, .arg = a.cmd(&.{"dolphin"}) },
    .{ .mod = MOD | ALT, .sym = K.e, .func = a.spawn, .arg = a.cmd(&.{ "foot", "zsh", "-ic", "y; exec zsh" }) },
    .{ .mod = CTRL | SHIFT, .sym = K.Escape, .func = a.spawn, .arg = a.cmd(&.{ "foot", "-e", "btop" }) },
    .{ .mod = MOD, .sym = K.d, .func = menu.launcher },
    .{ .mod = MOD, .sym = K.x, .func = menu.session },
    .{ .mod = MOD, .sym = K.i, .func = a.spawn, .arg = a.cmd(&.{helpers ++ "aion-caffeine"}) },
    .{ .mod = ALT, .sym = K.Tab, .func = a.focusstack, .arg = .{ .i = 1 } },
    .{ .mod = ALT | SHIFT, .sym = K.Tab, .func = a.focusstack, .arg = .{ .i = -1 } },

    .{ .mod = MOD, .sym = K.g, .func = a.toggleoverview },
    .{ .mod = MOD, .sym = K.q, .func = a.killclient },
    .{ .mod = MOD, .sym = K.b, .func = a.togglebar },
    .{ .mod = MOD | ALT, .sym = K.q, .func = a.forcekill },
    .{ .mod = MOD, .sym = K.v, .func = a.togglefloating },
    .{ .mod = MOD, .sym = K.p, .func = a.togglepin },

    .{ .mod = MOD, .sym = K.c, .func = a.centercolumn },
    .{ .mod = MOD, .sym = K.f, .func = a.togglefullwidth },
    .{ .mod = MOD, .sym = K.r, .func = a.cyclewidth, .arg = .{ .i = 1 } },
    .{ .mod = MOD | SHIFT, .sym = K.r, .func = a.cyclewidth, .arg = .{ .i = -1 } },
    .{ .mod = MOD, .sym = K.minus, .func = a.setwidth, .arg = .{ .f = -0.05 } },
    .{ .mod = MOD, .sym = K.equal, .func = a.setwidth, .arg = .{ .f = 0.05 } },
    .{ .mod = MOD | SHIFT, .sym = K.minus, .func = a.setheight, .arg = .{ .f = -0.1 } },
    .{ .mod = MOD | SHIFT, .sym = K.equal, .func = a.setheight, .arg = .{ .f = 0.1 } },
    .{ .mod = MOD, .sym = K.bracketleft, .func = a.consumeorexpel, .arg = .{ .i = -1 } },
    .{ .mod = MOD, .sym = K.bracketright, .func = a.consumeorexpel, .arg = .{ .i = 1 } },
    .{ .mod = MOD, .sym = K.Home, .func = a.focusend, .arg = .{ .i = -1 } },
    .{ .mod = MOD, .sym = K.End, .func = a.focusend, .arg = .{ .i = 1 } },
    .{ .mod = MOD | SHIFT, .sym = K.Home, .func = a.movecolumnend, .arg = .{ .i = -1 } },
    .{ .mod = MOD | SHIFT, .sym = K.End, .func = a.movecolumnend, .arg = .{ .i = 1 } },

    .{ .mod = MOD | SHIFT, .sym = K.f, .func = a.togglefullscreen },
    .{ .mod = MOD | CTRL, .sym = K.f, .func = a.togglefullscreen },

    .{ .mod = MOD, .sym = K.Tab, .func = a.view, .arg = .{ .ui = 0 } },

    // these also work while locked
    helper(0, K.XF86AudioRaiseVolume, &.{ helpers ++ "aion-volume", "up" }),
    helper(0, K.XF86AudioLowerVolume, &.{ helpers ++ "aion-volume", "down" }),
    helper(0, K.XF86AudioMute, &.{ helpers ++ "aion-volume", "mute" }),
    helper(0, K.XF86AudioMicMute, &.{ helpers ++ "aion-volume", "mic-mute" }),
    // no media keys on the aspire, so the numpad stands in; level 0 matches with numlock on or off
    helper(MOD, K.KP_Left, &.{ helpers ++ "aion-media", "previous" }),
    helper(MOD, K.KP_Begin, &.{ helpers ++ "aion-media", "play-pause" }),
    helper(MOD, K.KP_Right, &.{ helpers ++ "aion-media", "next" }),
    helper(MOD, K.KP_Up, &.{ helpers ++ "aion-volume", "up" }),
    helper(MOD, K.KP_Down, &.{ helpers ++ "aion-volume", "down" }),
    helper(0, K.XF86MonBrightnessUp, &.{ helpers ++ "aion-brightness", "up" }),
    helper(0, K.XF86MonBrightnessDown, &.{ helpers ++ "aion-brightness", "down" }),
    helper(ALT, K.XF86MonBrightnessUp, &.{ helpers ++ "aion-brightness", "up", "1" }),
    helper(ALT, K.XF86MonBrightnessDown, &.{ helpers ++ "aion-brightness", "down", "1" }),

    .{ .mod = 0, .sym = K.Print, .func = a.spawn, .arg = a.cmd(&.{ helpers ++ "aion-screenshot", "full" }) },
    .{ .mod = MOD | SHIFT, .sym = K.s, .func = a.spawn, .arg = a.cmd(&.{ helpers ++ "aion-screenshot", "region" }) },

    .{ .mod = CTRL | ALT, .sym = K.BackSpace, .func = a.quit },
} ++ both(MOD, K.h, K.Left, a.focusdir, a.dir(.left)) ++
    both(MOD, K.l, K.Right, a.focusdir, a.dir(.right)) ++
    both(MOD, K.k, K.Up, a.focusdir, a.dir(.up)) ++
    both(MOD, K.j, K.Down, a.focusdir, a.dir(.down)) ++
    both(MOD | SHIFT, K.h, K.Left, a.movecolumn, .{ .i = -1 }) ++
    both(MOD | SHIFT, K.l, K.Right, a.movecolumn, .{ .i = 1 }) ++
    both(MOD | SHIFT, K.k, K.Up, a.movewindow, .{ .i = -1 }) ++
    both(MOD | SHIFT, K.j, K.Down, a.movewindow, .{ .i = 1 }) ++
    both(MOD | CTRL, K.h, K.Left, a.focusmon, a.dir(.left)) ++
    both(MOD | CTRL, K.l, K.Right, a.focusmon, a.dir(.right)) ++
    both(MOD | CTRL, K.k, K.Up, a.focusmon, a.dir(.up)) ++
    both(MOD | CTRL, K.j, K.Down, a.focusmon, a.dir(.down)) ++
    both(MOD | SHIFT | CTRL, K.h, K.Left, a.tagmon, a.dir(.left)) ++
    both(MOD | SHIFT | CTRL, K.l, K.Right, a.tagmon, a.dir(.right)) ++
    both(MOD | SHIFT | CTRL, K.k, K.Up, a.tagmon, a.dir(.up)) ++
    both(MOD | SHIFT | CTRL, K.j, K.Down, a.tagmon, a.dir(.down)) ++
    tagKeys() ++ vtKeys();

/// mod with a wheel: tags up and down, columns sideways; touchpads fire once per axis_step
pub const axes = [_]a.Axis{
    .{ .mod = MOD, .dir = .up, .func = a.viewrel, .arg = .{ .i = -1 } },
    .{ .mod = MOD, .dir = .down, .func = a.viewrel, .arg = .{ .i = 1 } },
    .{ .mod = MOD | SHIFT, .dir = .up, .func = a.tagrel, .arg = .{ .i = -1 } },
    .{ .mod = MOD | SHIFT, .dir = .down, .func = a.tagrel, .arg = .{ .i = 1 } },
    .{ .mod = MOD, .dir = .left, .func = a.focusdir, .arg = a.dir(.left) },
    .{ .mod = MOD, .dir = .right, .func = a.focusdir, .arg = a.dir(.right) },
    .{ .mod = MOD | CTRL, .dir = .left, .func = a.movecolumn, .arg = .{ .i = -1 } },
    .{ .mod = MOD | CTRL, .dir = .right, .func = a.movecolumn, .arg = .{ .i = 1 } },
};
pub const axis_step = 40.0;
/// sideways touchpad scrolling with this held moves the strip instead of running the axes above
pub const scroll_mod = MOD;

/// fingers that drag the strip sideways, or slide in the next (up) or previous (down) tag
pub const scroll_fingers = 3;
pub const swipe_speed = 1.0;
/// travel that views a slid-in tag on release, and that other swipes need per step
pub const swipe_threshold = 120.0;
pub const gestures = [_]a.Gesture{
    .{ .fingers = 4, .dir = .left, .func = a.movecolumn, .arg = .{ .i = -1 } },
    .{ .fingers = 4, .dir = .right, .func = a.movecolumn, .arg = .{ .i = 1 } },
    .{ .fingers = 4, .dir = .up, .func = a.tagrel, .arg = .{ .i = 1 } },
    .{ .fingers = 4, .dir = .down, .func = a.tagrel, .arg = .{ .i = -1 } },
};

pub const buttons = [_]a.Button{
    .{ .click = .title, .mod = 0, .button = c.BTN_MIDDLE, .func = a.centercolumn },
    .{ .click = .client, .mod = MOD, .button = c.BTN_LEFT, .func = a.moveresize, .arg = .{ .ui = 0 } },
    .{ .click = .client, .mod = MOD, .button = c.BTN_RIGHT, .func = a.moveresize, .arg = .{ .ui = 1 } },
    .{ .click = .client, .mod = MOD, .button = c.BTN_MIDDLE, .func = a.scrolldrag },
    .{ .click = .root, .mod = MOD, .button = c.BTN_MIDDLE, .func = a.scrolldrag },
    .{ .click = .tagbar, .mod = 0, .button = c.BTN_LEFT, .func = a.view },
    .{ .click = .tagbar, .mod = 0, .button = c.BTN_RIGHT, .func = a.toggleview },
    .{ .click = .tagbar, .mod = MOD, .button = c.BTN_LEFT, .func = a.tag },
    .{ .click = .tagbar, .mod = MOD, .button = c.BTN_RIGHT, .func = a.toggletag },
};
