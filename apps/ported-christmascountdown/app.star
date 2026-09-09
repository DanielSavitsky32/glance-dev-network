# Ported from the tidbyt/community "Christmas Countdown" app
# (apps/christmascountdown/christmascountdown.star).
#
# ORIGINAL Pixlet: four base64 Christmas-tree PNG frames played as a
# render.Animation; beside the tree a render.Column shows "Merry" / "Christmas" /
# "<n> days" (days until Dec 25, computed with the time module).
#
# `gdn translate` converted the schema (3 colors + toggle + max value) and
# flagged base64/math/time/load() and the Animation/Row/Column/Image/Padding/Text
# widgets. Hand-finished for GDN (static 64x32): the DAYS-UNTIL-CHRISTMAS math
# ports (using ctx.now); the animated tree PNG became a static c.bitmap tree with
# a star and trunk; the text column ports directly.

TREE = [
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
]

MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

def is_leap(y):
    return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)

# The time zone is a four-way US dropdown resolved right here: no zip lookup
# and no time API, so every panel in a zone shares one render and a dead API
# can never cost the clock its offset.
#
# zone -> standard offset in minutes east of UTC. All four observe US daylight
# saving: 2nd Sunday in March 02:00 -> 1st Sunday in November 02:00.
US_ZONES = {"EASTERN": -300, "CENTRAL": -360, "MOUNTAIN": -420, "PACIFIC": -480,
            "America/New_York": -300, "America/Chicago": -360,
            "America/Denver": -420, "America/Los_Angeles": -480}


def _dfc(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def _nth_sunday(y, m, n):
    """Day of the month of the nth Sunday. 1970-01-01 was a Thursday."""
    wd = (_dfc(y, m, 1) + 4) % 7      # 0 = Sunday
    return 1 + (7 - wd) % 7 + 7 * (n - 1)


def offset_hours(ctx):
    """UTC offset for the chosen US zone, daylight saving already applied."""
    zone = str(ctx.inputs.get("timezone", "EASTERN")).strip()
    std = US_ZONES.get(zone.upper(), US_ZONES.get(zone, -300))
    t = ctx.now.unix // 60
    y = ctx.now.year
    start = _dfc(y, 3, _nth_sunday(y, 3, 2)) * 1440 + 120 - std
    end = _dfc(y, 11, _nth_sunday(y, 11, 1)) * 1440 + 120 - std - 60
    off = std + 60 if (t >= start and t < end) else std
    return off / 60.0


def _cfd(z):
    """Civil [y, m, d] from days since the epoch (Howard Hinnant)."""
    z += 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [y + (1 if m <= 2 else 0), m, d]


def days_until_christmas(ctx):
    # Today on the reader's wall clock, so the sleeps flip at local midnight.
    days = (ctx.now.unix + int(offset_hours(ctx) * 3600)) // 86400
    ymd = _cfd(days)
    y = ymd[0]
    today = days - _dfc(y, 1, 1) + 1
    # day-of-year of Dec 25 this year
    xmas = 25
    for i in range(11):
        xmas += MDAYS[i]
    if is_leap(y):
        xmas += 1
    if today <= xmas:
        return xmas - today
    diy = 366 if is_leap(y) else 365
    ny = 359 if not is_leap(y + 1) else 360
    return (diy - today) + ny

def main(c, ctx):
    days = days_until_christmas(ctx)

    c.fill("black")
    # tree (green), star (yellow), trunk (brown)
    c.bitmap(TREE, 2, 9, "green")
    c.pixel(7, 8, "yellow")
    c.rect(6, 21, 8, 23, fill = "#8a5a2b")
    # a couple of ornaments
    c.pixel(5, 13, "red")
    c.pixel(9, 16, "cyan")
    c.pixel(6, 19, "magenta")

    # text column to the right
    c.text("MERRY", 16, 4, font = "5x7", color = "red")
    c.text("CHRISTMAS", 16, 13, font = "4x5", color = "green")
    c.text(str(days) + " DAYS", 16, 21, font = "5x7", color = "#7aa0ff")
