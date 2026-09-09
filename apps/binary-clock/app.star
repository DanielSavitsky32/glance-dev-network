# Binary Clock
#
# Two ways to read the time in binary. BCD gives a column per decimal
# digit, the way a classic binary desk clock does; BITS gives one row
# per unit, which is easier to decode once you are used to it.



MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
DOW = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]


def is_leap(y):
    return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)


def days_from_civil(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


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


def local(ctx):
    """ctx.now shifted onto the viewer's wall clock."""
    shifted = ctx.now.unix + int(offset_hours(ctx) * 3600)
    days = shifted // 86400
    secs = shifted % 86400
    weekday = (days + 3) % 7           # 1970-01-01 was a Thursday
    y = 1970
    for i in range(400):
        span = 366 if is_leap(y) else 365
        if days < span:
            break
        days -= span
        y += 1
    m = 0
    yd = days
    for i in range(12):
        span = MDAYS[m] + (1 if (m == 1 and is_leap(y)) else 0)
        if days < span:
            break
        days -= span
        m += 1
    return {"year": y, "month": m + 1, "day": days + 1, "weekday": weekday,
            "yday": yd + 1, "hour": secs // 3600, "minute": (secs % 3600) // 60,
            "second": secs % 60, "secs": secs, "unix": shifted}


def h12(h):
    v = h % 12
    return 12 if v == 0 else v


BITS = [8, 4, 2, 1]


def dot(c, x, y, r, on, accent):
    if on:
        c.fill_circle(x, y, r, accent)
    else:
        c.circle(x, y, r, "#1E2233")


def bcd(c, ctx):
    """One column per decimal digit, lit dots reading downward as 8-4-2-1."""
    t = local(ctx)
    accent = ctx.inputs.get("accent", "#3FC8FF")
    digits = [t["hour"] // 10, t["hour"] % 10, t["minute"] // 10,
              t["minute"] % 10, t["second"] // 10, t["second"] % 10]

    c.fill("#05070E")
    r = 2 if c.width >= 128 else 1
    step = 2 * r + 3
    block = 6 * step + 2 * (2 * r + 2)
    # On the Scroll the dots take the left half and leave the right to the
    # faint plain reading; centring the block ran the two together.
    x0 = (8 + r) if c.width >= 128 else ((c.width - block) // 2 + r)
    y0 = (c.height - 4 * step) // 2 + r + 3

    for i in range(6):
        x = x0 + i * step + (i // 2) * (2 * r + 2)
        for b in range(4):
            dot(c, x, y0 + b * step, r, digits[i] // BITS[b] % 2 == 1, accent)
    c.text("H   M   S", x0 + 3 * step + r, 1, font = "4x5",
           color = "#4A5068", align = "center")
    if c.width >= 128:
        # The dot cluster alone leaves most of a 192 panel empty, so the Scroll
        # also carries the plain reading to check yourself against.
        c.text(fmt.pad(t["hour"]) + ":" + fmt.pad(t["minute"]),
               c.width - 10, 7, font = "16x20", color = "#22304A",
               align = "right")


def bits(c, ctx):
    """One row per unit: hours, minutes, seconds as plain binary."""
    t = local(ctx)
    accent = ctx.inputs.get("accent", "#3FC8FF")
    rows = [["H", t["hour"], 5], ["M", t["minute"], 6], ["S", t["second"], 6]]

    c.fill("#05070E")
    r = 2 if c.width >= 128 else 1
    # 64 wide: an 8px pitch so the H/M/S labels (5 tall) sit clear of each
    # other with 3 rows between, each still centered on its row of dots.
    step = 2 * r + 3 if c.width >= 128 else 8
    y0 = (c.height - 3 * step) // 2 + r

    for i in range(3):
        label = rows[i][0]
        val = rows[i][1]
        nbits = rows[i][2]
        y = y0 + i * step
        c.text(label, 3, y - 2, font = "4x5", color = "#4A5068")
        x0 = 11 + r
        for b in range(nbits):
            place = nbits - 1 - b
            p = 1
            for k in range(place):
                p = p * 2
            dot(c, x0 + b * step, y, r, val // p % 2 == 1, accent)
        if c.width >= 128:
            # 4x5, not 6x8: the row pitch here is 7px and an 8px glyph runs
            # straight into the row below it.
            c.text(fmt.pad(val), c.width - 6, y - 2, font = "4x5",
                   color = "#C8D0E8", align = "right")
