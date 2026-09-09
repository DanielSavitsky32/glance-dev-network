# Progress Clock
#
# Time as completion rather than as digits. The dial page puts the day
# on a 12-hour ring so the shape of the afternoon is visible at a
# glance from across the room.



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


def spans(ctx):
    t = local(ctx)
    yspan = 366.0 if is_leap(t["year"]) else 365.0
    return [
        ["HOUR", (t["minute"] * 60.0 + t["second"]) * 100.0 / 3600.0],
        ["DAY", t["secs"] * 100.0 / 86400.0],
        ["YEAR", (t["yday"] - 1 + t["secs"] / 86400.0) * 100.0 / yspan],
    ]


SHORT = ["HR", "DY", "YR"]


def bars(c, ctx):
    accent = ctx.inputs.get("accent", "#39D98A")
    rows = spans(ctx)
    c.fill("#07080E")
    h = 6 if c.width >= 128 else 5
    gap = 4
    y = (c.height - (3 * h + 2 * gap)) // 2
    wide = c.width >= 128
    lw = 26 if wide else 17
    rw = 26 if wide else 20
    for i in range(3):
        yy = y + i * (h + gap)
        label = rows[i][0] if wide else SHORT[i]
        c.text(label, 2, yy - 1, font = "4x5", color = "#6A7090")
        c.progress_bar(lw, yy, c.width - lw - rw, h, rows[i][1],
                       color = accent, bg = "#181C26")
        c.text(str(int(rows[i][1])) + "%", c.width - 2, yy - 1, font = "4x5",
               color = "#C8D0E8", align = "right")


def dial(c, ctx):
    """The day drawn as a 12-hour ring, filled to the current time."""
    t = local(ctx)
    accent = ctx.inputs.get("accent", "#39D98A")
    c.fill("#07080E")

    # On the Scroll the ring gets its own column so nothing is drawn over it;
    # on the 64 there is no room beside it, so the reading sits on a filled
    # disc that gives it a background of its own.
    wide = c.width >= 128
    r = c.height // 2 - 3
    cx = r + 3 if wide else c.width // 2
    cy = c.height // 2
    frac = ((t["hour"] % 12) * 3600.0 + t["minute"] * 60.0 + t["second"]) / 43200.0

    steps = 48
    for i in range(steps):
        a = -math.pi / 2 + 2 * math.pi * i / steps
        col = accent if i < int(frac * steps) else "#20242F"
        c.pixel(cx + int(math.cos(a) * r), cy + int(math.sin(a) * r), col)
        c.pixel(cx + int(math.cos(a) * (r - 1)), cy + int(math.sin(a) * (r - 1)), col)

    label = str(h12(t["hour"])) + ":" + fmt.pad(t["minute"])
    if wide:
        c.text(label, cx + r + 12, 6, font = "16x20", color = "#FFFFFF")
        c.text("AM" if t["hour"] < 12 else "PM", c.width - 6, 4, font = "6x8",
               color = accent, align = "right")
        c.text(DOW[t["weekday"]], c.width - 6, 20, font = "6x8",
               color = "#6A7090", align = "right")
    else:
        c.fill_circle(cx, cy, r - 3, "#0B0D14")
        c.text(label, cx, cy - 3, font = "6x8", color = "#FFFFFF",
               align = "center")
