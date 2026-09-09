# Halloween Horror Nights Orlando for a Glance SCROLL panel (192x32).
#
# DESIGN. One park (Universal Studios Florida), one event, four pages, no
# mascot (no licensed icons — Jack the Clown and Dr. Oddfellow are
# Universal's trademarks). A masthead bar spells the event name in a
# state-colored bar across the top of every page. Page 1 is the splash: a
# cold moon over an uneven row of tombstones, silhouetted in front of it —
# scenery doing the identifying instead of a friendly face. Page 2's content
# band is one big bold hero: tonight's gates (open now / opens at) or, on a
# dark night, a countdown to the next one. Pages 3 and 4 split all ten
# haunted houses five to a page, plain-listed two roomy columns wide: real
# name left, wait time colored right, no boxes or pills. Two columns instead
# of three gives each name about 50% more room, so almost all show in full.
# Off nights the house pages don't fake a wait grid full of dashes — they
# say plainly that the houses open at gates. Every page sits on a near-black
# dusk gradient instead of flat black, for a little mood without giving up
# any contrast.
#
# Data: api.themeparks.wiki. /schedule's TICKETED_EVENT entries are individual
# HHN nights (one per date, not a season range), so "is it on tonight" and
# "how many nights until it is" both fall out of the same list. /live's
# haunted-house attractions carry externalId "hhn_haunted_house_*" with a
# normal STANDBY queue once the event is running. One park, two fetches.

API = "https://api.themeparks.wiki/v1/entity/"
PARK_ID = "eb3f4560-2383-4a36-9152-6b3e5ed6bc57"   # Universal Studios Florida
TTL = 900                 # matches refresh: in the manifest

TITLE = "HALLOWEEN HORROR NIGHTS ORLANDO"   # this app is Orlando-only

INK = "#F4F7FF"
DIM = "#6E7A94"
ORANGE = "#FF6A00"        # HHN's own accent
PURPLE = "#7521F9"
OFFLINE = "#3C4043"

NIGHT_A = "#07050C"       # near-black, a hair of purple in it
NIGHT_B = "#15101F"       # ...fading into a slightly lighter dusk at the
                          # bottom - a mood wash, never bright enough to
                          # cost the text any contrast.

def night(c):
    c.gradient_rect(0, 0, c.width - 1, c.height - 1, NIGHT_A, NIGHT_B,
                     horizontal = False)

EDGEL = 6                 # 6 px clear at both outer edges, like its sibling app
RZ_R = 185
MIDX = (EDGEL + RZ_R) // 2

STATE_COLOR = {"open": "green", "tonight": ORANGE, "countdown": PURPLE,
               "offseason": DIM}

def masthead(c, text, color):
    """A state-colored bar edge to edge (its own solid block is frame enough
    to read as this app's own unit, so it doesn't need the 6px safe-zone
    inset), bold enough on its own that the page needs no pictorial logo
    under it. Plain contrasting text, no stroke: the bar is a flat fill, not
    artwork, so a stroke only added a boxed-per-word look instead of
    contrast. Centered on c.width, not the content zone, so it's dead center
    on the bar itself."""
    c.rect(0, 0, c.width - 1, 7, fill = color)
    ink = "white" if color in (PURPLE, DIM, OFFLINE) else "black"
    c.text(text, c.width // 2, 1, font = "4x5", color = ink, align = "center")

# ---- text kit (identical contract to the sibling app's) -------------------
def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def clip_words(c, text, font, maxw):
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 10 >= len(t) * 7:
        return t[:sp]
    return t

KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -&.'!:"

def clean_name(name):
    out = ""
    for ch in str(name).upper().elems():
        if KEEP.find(ch) >= 0:
            out = out + ch
    parts = []
    for p in out.split(" "):
        if p != "":
            parts.append(p)
    return " ".join(parts)

# Only the handful of houses with a promotional subtitle ("X Presents: Y")
# get shortened here, down to the part people actually call the house.
# Everything else keeps its real name and only clips (at a word boundary)
# if the column genuinely can't fit it.
HOUSE_NICKS = [
    ["BLOODENGUTZ", "FRIGHT-TACULAR"], ["ODDFELLOW", "JACK & ODDFELLOW"],
    ["MADLANDS", "MADLANDS"], ["INVASION", "INVASION"],
    ["OZZY OSBOURNE", "OZZY OSBOURNE"],
]

def house_name(c, raw, room):
    t = clean_name(raw)
    for n in HOUSE_NICKS:
        if t.find(n[0]) >= 0:
            t = n[1]
            break
    if c.text_width(t, "4x5") <= room:
        return t
    return clip_words(c, t, "4x5", room)

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def lst(obj, key):
    v = get(obj, key, [])
    return v if type(v) == "list" else []

# ---- Eastern time, no network (same civil-calendar math as the sibling app) -
def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil_from_days(z):
    zz = z + 719468
    era = (zz if zz >= 0 else zz - 146096) // 146097
    doe = zz - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    return [y + 1 if m <= 2 else y, m, d]

def nth_sunday(y, m, n):
    wd = (days_from_civil(y, m, 1) + 3) % 7        # 0 = Monday
    first = 1 + ((6 - wd) % 7)
    return first + 7 * (n - 1)

def eastern_minutes(unix):
    """Minutes since the epoch on Orlando's wall clock. US rule: daylight
    time from the 2nd Sunday in March at 2 AM to the 1st Sunday in November
    at 2 AM, all compared in UTC."""
    t = unix // 60
    y = civil_from_days(t // 1440)[0]
    std = -300
    start = days_from_civil(y, 3, nth_sunday(y, 3, 2)) * 1440 + 120 - std
    end = days_from_civil(y, 11, nth_sunday(y, 11, 1)) * 1440 + 120 - std - 60
    off = std + 60 if t >= start and t < end else std
    return t + off

def two(v):
    return ("0" + str(v)) if v < 10 else str(v)

def date_key(ymd):
    return str(ymd[0]) + "-" + two(ymd[1]) + "-" + two(ymd[2])

def iso_minutes(value):
    t = str(value)
    if len(t) < 16:
        return -1
    return int(t[11:13]) * 60 + int(t[14:16])

def iso_ymd(value):
    """[y, m, d] out of an ISO stamp's own date, no timezone math needed:
    themeparks.wiki always hands back the park's local wall clock."""
    t = str(value)
    if len(t) < 10:
        return None
    return [int(t[0:4]), int(t[5:7]), int(t[8:10])]

def epoch_minutes_iso(value):
    """Absolute minutes on the same wall-clock scale as eastern_minutes(),
    so a closing time past midnight compares correctly against `now`."""
    ymd = iso_ymd(value)
    if ymd == None:
        return -1
    return days_from_civil(ymd[0], ymd[1], ymd[2]) * 1440 + iso_minutes(value)

def clock(value):
    m = iso_minutes(value)
    if m < 0:
        return ""
    h = m // 60
    mm = m % 60
    ap = "A" if h < 12 else "P"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    if mm == 0:
        return str(h12) + ap
    return str(h12) + ":" + two(mm) + ap

MONTH = ["", "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP",
         "OCT", "NOV", "DEC"]

def month_day(ymd):
    return MONTH[ymd[1]] + " " + str(ymd[2])

# ---- feed -------------------------------------------------------------------
def fetch(path):
    r = http.get(API + path, headers = {"accept": "application/json"},
                 ttl_seconds = TTL)
    if r["status_code"] != 200:
        return None
    return r["json"]

def is_hhn(entry):
    if get(entry, "type", "") != "TICKETED_EVENT":
        return False
    return str(get(entry, "description", "")).upper().find("HALLOWEEN") >= 0

def standby(entry):
    q = get(entry, "queue", {})
    sb = get(q, "STANDBY")
    if sb == None:
        return None
    w = get(sb, "waitTime")
    if w == None or type(w) != "int":
        return None
    if w < 0 or w > 300:
        return None
    return w

def read_hhn(ctx):
    """Everything both pages draw, display-ready, or {"online": False}."""
    dbg = str(ctx.inputs.get("_debugstate", "")).strip().lower()
    if dbg != "":
        return demo_state(dbg)

    live = fetch(PARK_ID + "/live")
    sched = fetch(PARK_ID + "/schedule")
    if live == None and sched == None:
        return {"online": False}

    rows = lst(live, "liveData")
    entries = lst(sched, "schedule")

    now_abs = eastern_minutes(ctx.now.unix)
    today = civil_from_days(now_abs // 1440)
    today_key = date_key(today)
    today_day = days_from_civil(today[0], today[1], today[2])

    nights = [e for e in entries if is_hhn(e)]
    tonight = None
    next_night = None
    for e in nights:
        if get(e, "date", "") == today_key:
            tonight = e
        elif next_night == None and get(e, "date", "") > today_key:
            next_night = e

    houses = []
    for e in rows:
        ext = str(get(e, "externalId", ""))
        if ext.find("hhn_haunted_house") < 0:
            continue
        houses.append([standby(e), get(e, "name", "")])
    houses = sorted(houses, key = lambda r: -1 if r[0] == None else -r[0])

    if tonight != None:
        open_abs = epoch_minutes_iso(get(tonight, "openingTime"))
        close_abs = epoch_minutes_iso(get(tonight, "closingTime"))
        return {
            "online": True, "state": "open" if now_abs >= open_abs else "tonight",
            "hours": [clock(get(tonight, "openingTime")), clock(get(tonight, "closingTime"))],
            "houses": houses,
        }

    if next_night != None:
        ymd = iso_ymd(get(next_night, "date") + "T00:00:00")
        night_day = days_from_civil(ymd[0], ymd[1], ymd[2])
        return {
            "online": True, "state": "countdown", "days": night_day - today_day,
            "date": month_day(ymd),
            "hours": [clock(get(next_night, "openingTime")), clock(get(next_night, "closingTime"))],
            "houses": [],
        }

    return {"online": True, "state": "offseason", "houses": []}

# Sample states for previewing every screen while off event nights:
# _debugstate = open | tonight | countdown | offseason | offline.
DEMO_HOUSES = [
    [75, "Hellraiser"], [60, "Stranger Things 5"], [55, "Sinners"],
    [50, "INVASION: Alien Abduction"], [45, "Cybergoria"],
    [40, "Ozzy Osbourne: Prince of Darkness"], [35, "Evil Dead Burn"],
    [30, "MADLANDS: Caged Cannibals"], [25, "Jack & Oddfellow: Chaos & Control"],
    [20, "H.R. Bloodengutz Presents: A Halloween Fright-Tacular!"],
]

def demo_state(dbg):
    if dbg == "offline":
        return {"online": False}
    if dbg == "open":
        return {"online": True, "state": "open", "hours": ["6:30P", "2A"], "houses": DEMO_HOUSES}
    if dbg == "tonight":
        return {"online": True, "state": "tonight", "hours": ["6:30P", "2A"], "houses": []}
    if dbg == "countdown":
        return {"online": True, "state": "countdown", "days": 3, "date": "SEP 12",
                "hours": ["6:30P", "1A"], "houses": []}
    return {"online": True, "state": "offseason", "houses": []}

# ---- wait color (same bands as the sibling app) ------------------------------
def wait_color(w):
    if w == None:
        return DIM
    if w < 30:
        return "green"
    if w < 60:
        return "amber"
    if w < 90:
        return "orange"
    return "red"

# ---- drawing ------------------------------------------------------------------
def offline_card(c):
    masthead(c, TITLE, OFFLINE)
    c.text("HHN DATA UNREACHABLE", MIDX, 14, font = "5x7", color = "amber",
           align = "center")
    c.text("TRY AGAIN NEXT REFRESH", MIDX, 25, font = "4x5", color = DIM,
           align = "center")

def tonight(c, ctx):
    night(c)
    st = read_hhn(ctx)
    if not st["online"]:
        offline_card(c)
        return

    color = STATE_COLOR[st["state"]]
    masthead(c, TITLE, color)

    if st["state"] == "open":
        c.text("OPEN NOW", MIDX, 9, font = "10x16_bold", color = color,
               align = "center")
        c.text("GATES OPEN TIL " + st["hours"][1], MIDX, 27, font = "4x5",
               color = DIM, align = "center")
    elif st["state"] == "tonight":
        c.text("TONIGHT", MIDX, 9, font = "10x16_bold", color = color,
               align = "center")
        c.text("GATES OPEN AT " + st["hours"][0], MIDX, 27, font = "4x5",
               color = DIM, align = "center")
    elif st["state"] == "countdown":
        unit = " NIGHT" if st["days"] == 1 else " NIGHTS"
        c.text(str(st["days"]) + unit, MIDX, 9, font = "10x16_bold",
               color = color, align = "center")
        sub = "TIL OPENING - " + st["date"] + " " + st["hours"][0] + "-" + st["hours"][1]
        c.text(sub, MIDX, 27, font = "4x5", color = DIM, align = "center")
    else:
        c.text("SEE YOU NEXT FALL", MIDX, 15, font = "6x8", color = color,
               align = "center")

# Five houses to a page, as a plain list: two roomy columns of three rows,
# name left and wait time right in plain colored text - no boxes, no pills.
# Two columns instead of the original three means each name gets about 50%
# more width, so most show their real name in full; only the handful with a
# long promotional subtitle ("X Presents: Y") get shortened to the part
# people actually call the house, via HOUSE_NICKS below.
LIST_COLS = 2
LIST_ROWS = 3
LIST_GAP = 4

def house_row(c, x0, colw, y, w, name):
    mins = (str(w) + "M") if w != None else "-"
    col = wait_color(w)
    mw = c.text_width(mins, "4x5")
    c.text(mins, x0 + colw - mw, y, font = "4x5", color = col)
    c.text(house_name(c, name, colw - mw - 4), x0, y, font = "4x5", color = INK)

def house_cards(c, ctx, title, lo, hi):
    night(c)
    st = read_hhn(ctx)
    if not st["online"]:
        masthead(c, title, OFFLINE)
        c.text("HHN DATA UNREACHABLE", MIDX, 14, font = "5x7", color = "amber",
               align = "center")
        c.text("TRY AGAIN NEXT REFRESH", MIDX, 25, font = "4x5", color = DIM,
               align = "center")
        return

    page = st["houses"][lo:hi]
    if st["state"] == "open" and len(page) > 0:
        masthead(c, title + "  -  TIL " + st["hours"][1], STATE_COLOR["open"])
        colw = (RZ_R - EDGEL + 1 - LIST_GAP * (LIST_COLS - 1)) // LIST_COLS
        for i, row in enumerate(page):
            col = i // LIST_ROWS
            slot = i % LIST_ROWS
            x0 = EDGEL + col * (colw + LIST_GAP)
            y = 10 + slot * 8   # 3px clear of the masthead, not touching it
            house_row(c, x0, colw, y, row[0], row[1])
    else:
        # Two lines, evenly split around the middle of the content band
        # (y8-31): a label at y12, the value at y20, so the block sits with
        # equal breathing room from the masthead above and the edge below,
        # instead of crowding one side.
        color = STATE_COLOR[st["state"]]
        masthead(c, title, color)
        if st["state"] == "open":
            # Gates are open but the feed hasn't posted this page's houses yet
            # (or, on the second page, there just aren't that many tonight).
            label = "WAITS POSTING SOON" if lo == 0 else "THAT'S ALL OF THEM"
            c.text(label, MIDX, 12, font = "4x5", color = DIM, align = "center")
            c.text("CHECK BACK SHORTLY" if lo == 0 else "SEE PAGE 1", MIDX, 20,
                   font = "4x5", color = ORANGE, align = "center")
        elif st["state"] == "tonight":
            c.text("HOUSES OPEN AT GATES", MIDX, 12, font = "4x5", color = DIM,
                   align = "center")
            c.text(st["hours"][0], MIDX, 20, font = "6x8", color = ORANGE,
                   align = "center")
        elif st["state"] == "countdown":
            c.text("NO EVENT TONIGHT", MIDX, 12, font = "4x5", color = DIM,
                   align = "center")
            c.text("NEXT: " + st["date"], MIDX, 20, font = "6x8", color = ORANGE,
                   align = "center")
        else:
            c.text("HHN RETURNS THIS FALL", MIDX, 16, font = "5x7", color = DIM,
                   align = "center")

def houses1(c, ctx):
    house_cards(c, ctx, "HAUNTED HOUSES", 0, 5)

def houses2(c, ctx):
    house_cards(c, ctx, "MORE HOUSES", 5, 10)

# ---- splash: a crooked haunted house on a hill, under a bright moon -------
# A silhouette drawn in near the background color is invisible on real LED
# hardware, not moody - so the house is a clearly lighter moonlit gray (not
# a same-as-background cutout), the moon is bright and high-contrast, and
# every bat sits over the moon's disc so it reads as a dark shape against
# something bright, never dark-on-dark.
MOON = "#FFF6DC"
IRON = "#5C5578"          # moonlit gray — well clear of the night sky behind it
HILL = "#241D30"          # a shade of the sky itself, just enough lighter to
                          # separate the ground from the night behind it
WINDOW = "#FFD27A"
BAT = "#100C18"
FOG = "#6B6485"           # clearly lighter than the sky, so it reads as mist
                          # instead of vanishing like the first draft's silhouettes did

def hill(c, cx, ground, r, color):
    """A rounded mound: a circle centered below the panel so only its cap
    shows, clipped by the canvas edge - cheaper than tracing an arc by hand."""
    c.fill_circle(cx, ground + r - 5, r, color)

def house(c, x0, base):
    """A crooked haunted house: a lopsided gabled body, a taller narrow
    tower with a witch's-hat cap, two lit windows. Built tall on purpose —
    the title text crosses the middle of the panel, so the roofline needs to
    clear it on top and the windows need to sit low enough to clear it on
    the bottom; only the plain stretch of wall in between is meant to hide
    behind the title, same as a movie poster's logo over its artwork."""
    bw = 34
    body_top = base - 9
    c.rect(x0, body_top, x0 + bw, base, fill = IRON)
    mid = x0 + bw // 2
    c.line(x0 - 2, body_top, mid, 5, IRON)
    c.line(x0 + bw + 2, body_top, mid, 5, IRON)

    tower_top = 9
    c.rect(x0 + bw - 9, tower_top, x0 + bw - 1, base, fill = IRON)
    c.line(x0 + bw - 10, tower_top, x0 + bw - 5, tower_top - 6, IRON)
    c.line(x0 + bw, tower_top, x0 + bw - 5, tower_top - 6, IRON)

    c.pixel(x0 + 8, base - 4, WINDOW)
    c.pixel(x0 + bw - 5, base - 4, WINDOW)

def bat(c, x, y):
    c.pixel(x - 2, y, BAT)
    c.pixel(x - 1, y - 1, BAT)
    c.pixel(x, y, BAT)
    c.pixel(x + 1, y - 1, BAT)
    c.pixel(x + 2, y, BAT)

def fog_bank(c, y, color, step, offset):
    for x in range(EDGEL + offset, RZ_R, step):
        c.hline(x, y, step - 3, color)

def splash(c, ctx):
    night(c)
    c.fill_circle(152, 16, 10, MOON)

    # Every bat sits well inside the moon's disc (not near its rim) - a wing
    # tip that spills onto the night sky just vanishes, since both are the
    # same near-black.
    bat(c, 149, 13)
    bat(c, 156, 18)
    bat(c, 152, 21)

    hill(c, 96, 31, 22, HILL)
    house(c, 79, 30)

    # Fog rolling in front of the hill's base, two staggered bands so it
    # reads as drifting layers rather than a single straight line.
    fog_bank(c, 29, FOG, 11, 0)
    fog_bank(c, 31, FOG, 11, 6)

    # A true title card: the name sits ON the scene, not on a bar above it.
    # Stroked in black so it stays legible wherever it crosses the house,
    # the sky, or the moon. One font throughout each line - no letter drawn
    # differently from the rest (an earlier font's "A" was a shorter,
    # curvier glyph than its other capitals; these keep every letter the
    # same size). "ORLANDO" is its own smaller line underneath because the
    # full name doesn't fit one line at a readable size on a 192px panel.
    c.text_stroke("HALLOWEEN HORROR NIGHTS", c.width // 2, 11, font = "6x8",
                  color = ORANGE, stroke = "black", align = "center")
    c.text_stroke("ORLANDO", c.width // 2, 23, font = "4x5",
                  color = ORANGE, stroke = "black", align = "center")
