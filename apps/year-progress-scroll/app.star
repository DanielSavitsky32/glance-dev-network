# Year Progress — how much of the year, month and day are already gone.
#
# One page per horizon, so the panel cycles through the three scales. Pure
# ctx.now arithmetic: no network, nothing to fail.
#
# ctx.now is UTC, so it is shifted to your wall clock before any of the
# boundaries are worked out — otherwise "today" would tick over at the wrong
# moment for most of the world. The offset comes from a four-way US time zone
# dropdown, resolved locally with daylight saving applied, so there is nothing
# to look up and nothing to adjust twice a year.

MONTHS = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY",
          "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]


def is_leap(y):
    return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)


def days_from_civil(y, m, d):
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

    # Walk the day count back to a civil date.
    y = 1970
    for i in range(400):
        span = 366 if is_leap(y) else 365
        if days < span:
            break
        days -= span
        y += 1
    m = 0
    for i in range(12):
        span = MDAYS[m] + (1 if (m == 1 and is_leap(y)) else 0)
        if days < span:
            break
        days -= span
        m += 1
    return {"year": y, "month": m + 1, "day": days + 1,
            "hour": secs // 3600, "minute": (secs % 3600) // 60,
            "secs": secs}


def screen(c, title, pct, sub, accent):
    """Every element gets an explicit, non-overlapping band of the 32 rows.

    Row 31 is deliberately left empty on both: text flush against the bottom
    edge of a physical panel reads as clipped even when it is not.

    Wide:   0-6 title | 9-24 figure | 26-30 bar
    Narrow: 0-4 title | 6-21 figure | 22-24 bar | 26-30 detail
    """
    c.fill("#0A0A10")
    figure = "%d%%" % int(pct)

    if c.width >= 128:
        c.text(title, 6, 0, font = "5x7", color = "#7C7C9C")
        c.text(figure, 6, 9, font = "10x16", color = accent)
        c.text(sub, c.width - 6, 13, font = "5x7", color = "#C8C8E0",
               align = "right")
        c.progress_bar(6, 26, c.width - 12, 5, pct, color = accent,
                       bg = "#1B1B26", border = "#33334A")
    else:
        c.text(title, c.width // 2, 0, font = "4x5", color = "#7C7C9C",
               align = "center")
        c.text(figure, c.width // 2, 6, font = "10x16", color = accent,
               align = "center")
        c.progress_bar(3, 22, c.width - 6, 3, pct, color = accent,
                       bg = "#1B1B26")
        c.text(sub, c.width // 2, 26, font = "4x5", color = "#C8C8E0",
               align = "center")


def year(c, ctx):
    t = local(ctx)
    accent = ctx.inputs.get("accent", "#39D98A")
    span = 366 if is_leap(t["year"]) else 365
    gone = days_from_civil(t["year"], t["month"], t["day"]) \
        - days_from_civil(t["year"], 1, 1)
    pct = (gone + t["secs"] / 86400.0) * 100.0 / span
    screen(c, str(t["year"]), pct, "%d DAYS LEFT" % (span - gone), accent)


def month(c, ctx):
    t = local(ctx)
    accent = ctx.inputs.get("accent", "#39D98A")
    span = MDAYS[t["month"] - 1]
    if t["month"] == 2 and is_leap(t["year"]):
        span = 29
    pct = (t["day"] - 1 + t["secs"] / 86400.0) * 100.0 / span
    screen(c, MONTHS[t["month"] - 1], pct, "%d DAYS LEFT" % (span - t["day"]),
           accent)


def today(c, ctx):
    t = local(ctx)
    accent = ctx.inputs.get("accent", "#39D98A")
    pct = t["secs"] * 100.0 / 86400.0
    left = 1440 - (t["secs"] // 60)
    screen(c, "TODAY", pct, "%dH %dM LEFT" % (left // 60, left % 60), accent)
