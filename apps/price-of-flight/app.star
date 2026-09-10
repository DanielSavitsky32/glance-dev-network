# Flight Fare Tracker for a Glance SCROLL panel (192x32).
#
# DESIGN. One flight, one number. The chip row names the airline and flight
# in the carrier's own color (a color is not a logo, so no imitation marks)
# and, at the right, says whether today's fare is LOW, TYPICAL or HIGH for
# the route, straight from Google Flights' price insights. Under it a
# pixel-art airliner climbs out on the left through a couple of clouds; the
# route reads MCO -> JFK in the middle with the date, cabin and traveler
# count beneath; and the fare is the hero on the right, in the color of its
# verdict. With no API key the panel shows a labelled DEMO fare so the
# layout can be seen before a key is pasted in. Every missing setting and
# every API failure gets its own two-line card: what, and what to do.
#
# Data: SerpApi's Google Flights engine, one search per refresh. The search
# is a normal one-way query for the route and date; the itinerary whose
# first segment is the requested flight number is the fare shown. If Google
# does not list that flight, the lowest fare on the route is shown instead,
# labelled so. The key is the viewer's own, so the quota is theirs alone:
# every two hours is about 12 searches a day, and a flight that has already
# departed is never searched for.

TTL = 7200                # matches refresh: in the manifest

INK = "#F4F7FF"
DIM = "#6E7A94"
GREEN = "#42FF78"
AMBER = "#F0B44D"
RED = "#FF4D5E"
SKY = "#63B4FF"
OFFLINE = "#3C4043"
STRUCT = "darkgray"

# ---- geometry ----------------------------------------------------------------
# 6 px clear at both outer edges. Chip row y 0..6, content band y 8..31.
# Plane x 6..37, route block x 42..114, fare right-aligned at x 185 in a
# 68 px column: "$999" is 67 px at 16x20, five-digit fares drop to 10x16.
EDGEL = 6
RZ_R = 185
PLANEX = 6
ROUTEX = 42
ROUTEW = 72               # x 42..113; the fare column starts at 118
FAREW = 68

# Two-letter IATA code -> [name, brand color]. A code not listed here gets a
# white chip with the code itself, so nothing ever falls through unlabelled.
AIRLINES = {
    "B6": ["JETBLUE", "#3B7DFF"], "DL": ["DELTA", "#E51937"],
    "AA": ["AMERICAN", "#2E8BFF"], "UA": ["UNITED", "#3A86FF"],
    "WN": ["SOUTHWEST", "#FFBF27"], "AS": ["ALASKA", "#2AA8D8"],
    "NK": ["SPIRIT", "#FFE500"], "F9": ["FRONTIER", "#1FC96B"],
    "HA": ["HAWAIIAN", "#E040A0"], "G4": ["ALLEGIANT", "#F5A623"],
    "SY": ["SUN COUNTRY", "#FF7A2A"], "AC": ["AIR CANADA", "#F01428"],
    "WS": ["WESTJET", "#22B8A8"], "AM": ["AEROMEXICO", "#2A5BD7"],
    "BA": ["BRITISH AIRWAYS", "#4A8CFF"], "VS": ["VIRGIN ATLANTIC", "#E10A0A"],
    "LH": ["LUFTHANSA", "#FFB400"], "AF": ["AIR FRANCE", "#3A6BFF"],
    "KL": ["KLM", "#00A1DE"], "IB": ["IBERIA", "#F0B41E"],
    "EK": ["EMIRATES", "#D71921"], "QR": ["QATAR", "#A0286A"],
    "EI": ["AER LINGUS", "#1FC96B"], "TP": ["TAP", "#2ABF6A"],
}

MONTH = ["", "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP",
         "OCT", "NOV", "DEC"]

# ---- pixel art ---------------------------------------------------------------
PLANE_LEG = {"F": "#E8ECF4", "f": "#A8B0C4", "B": SKY, "E": "#6E7A94", "T": SKY}
# An airliner in profile, nose to the right, 32 x 11.
PLANE = """
..TT............................
..TTT...........................
..TTTT..........................
..TTTTT.........................
.FFFFFFFFFFFFFFFFFFFFFFFFFFF....
FFFFFFFBFBFBFBFBFBFBFBFBFBFFFF..
.FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF.
..ffffffffffffffffffffffffffff..
........fffffffffffff...........
..........EEEEffff..............
...........EEE..................
"""
CLOUD = """
...###...
.#######.
#########
..#####..
"""
ARROW = """
......#..
.......#.
#########
.......#.
......#..
"""

def scene(c):
    """The plane and its clouds: drawn before any fetch, so the app always
    identifies itself."""
    c.sprite(CLOUD, PLANEX + 1, 24, color = "#3A4A68")
    c.sprite(CLOUD, PLANEX + 20, 26, color = "#2E3C58")
    c.sprite(PLANE, PLANEX, 10, legend = PLANE_LEG)

# ---- text kit -----------------------------------------------------------------
def clip(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    """[font, text]: the largest font that fits, hard-clipped in the smallest."""
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return [f, text]
    return [fonts[len(fonts) - 1], clip(c, text, fonts[len(fonts) - 1], maxw)]

FONTH = {"16x20": 20, "10x16": 16, "8x10": 10, "6x8": 8, "5x7": 7, "4x5": 5}

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def lst(obj, key):
    v = get(obj, key, [])
    return v if type(v) == "list" else []

def luma(hexcol):
    """Perceived brightness 0-255 of a #RRGGBB, to pick black or white text."""
    h = str(hexcol)
    if len(h) != 7:
        return 128
    r = int(h[1:3], 16)
    g = int(h[3:5], 16)
    b = int(h[-2:], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

# ---- inputs --------------------------------------------------------------------
def only(s, allowed):
    out = ""
    for ch in str(s).upper().elems():
        if allowed.find(ch) >= 0:
            out = out + ch
    return out

LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
ALNUM = LETTERS + "0123456789"

def flight_parts(raw):
    """"b6 1234" / "B6-1234" -> ["B6", "1234"]; "" when it is not a flight."""
    t = only(raw, ALNUM)
    if len(t) < 3:
        return ["", ""]
    # the number starts at the first digit after the two-letter code
    i = 2
    for k in range(2, len(t)):
        if LETTERS.find(t[k]) >= 0:
            i = k + 1
        else:
            break
    code = t[:2]
    num = t[i:]
    if num == "":
        return ["", ""]
    return [code, num]

def parse_date(raw):
    """The date picker sends "2026-10-01T01" (cut at the first colon), so
    read the digits: [y, m, d] or None."""
    ds = only(raw, "0123456789")
    if len(ds) < 8:
        return None
    y, m, d = int(ds[0:4]), int(ds[4:6]), int(ds[6:8])
    if y < 2000 or m < 1 or m > 12 or d < 1 or d > 31:
        return None
    return [y, m, d]

def two(v):
    return ("0" + str(v)) if v < 10 else str(v)

def days_from_civil(y, m, d):
    """Days since 1970-01-01, to compare the departure date with today."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    doy = (153 * (m + (-3 if m > 2 else 9)) + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def cabin_api(v):
    return {"PREMIUM": "2", "BUSINESS": "3", "FIRST": "4"}.get(str(v).upper(), "1")

def cabin_label(v):
    return {"PREMIUM": "PREMIUM", "BUSINESS": "BUSINESS",
            "FIRST": "FIRST"}.get(str(v).upper(), "ECONOMY")

# ---- fare lookup -------------------------------------------------------------------
def lookup(apikey, code, num, origin, dest, ymd, adults, cabin):
    """[status, fare, level, exact] where status is "ok" or an error card key."""
    params = {
        "engine": "google_flights",
        "departure_id": origin,
        "arrival_id": dest,
        "outbound_date": str(ymd[0]) + "-" + two(ymd[1]) + "-" + two(ymd[2]),
        "type": "2",                      # one way
        "adults": str(adults),
        "travel_class": cabin_api(cabin),
        "currency": "USD",
        "hl": "en",
        "gl": "us",
        "api_key": apikey,
    }
    # ttl matches the manifest's refresh: one SerpApi search per refresh.
    r = http.get("https://serpapi.com/search.json", params = params,
                 ttl_seconds = TTL)
    status = r["status_code"]
    if status == 0:
        return ["offline", None, "", False]
    if status == 401 or status == 403:
        return ["badkey", None, "", False]
    if status == 429:
        return ["limit", None, "", False]
    if status == 400:
        return ["badrequest", None, "", False]
    if status != 200 or r["json"] == None:
        return ["offline", None, "", False]
    data = r["json"]
    if str(get(data, "error", "")) != "":
        return ["badrequest", None, "", False]

    want = code + num
    its = lst(data, "best_flights") + lst(data, "other_flights")
    exact = None
    lowest = None
    for it in its:
        price = get(it, "price")
        if type(price) != "int" and type(price) != "float":
            continue
        if lowest == None or price < lowest:
            lowest = price
        segs = lst(it, "flights")
        if len(segs) == 0:
            continue
        fn = only(get(segs[0], "flight_number", ""), ALNUM)
        if fn == want and (exact == None or price < exact):
            exact = price
    ins = get(data, "price_insights", {})
    level = str(get(ins, "price_level", "")).upper()
    if exact != None:
        return ["ok", exact, level, True]
    if lowest != None:
        return ["ok", lowest, level, False]
    return ["nofare", None, "", False]

def level_meta(level):
    if level == "LOW":
        return ["LOW FARE", GREEN]
    if level == "HIGH":
        return ["HIGH FARE", RED]
    if level == "TYPICAL":
        return ["TYPICAL", AMBER]
    return ["", DIM]

# ---- drawing ------------------------------------------------------------------------
def chip_row(c, label, chip_color, demo, meta, meta_color):
    """Airline chip, an amber DEMO chip when there is no key, and the fare
    verdict right-aligned. The chip is trimmed to what the row leaves."""
    metaw = c.text_width(meta, "4x5") + 6 if meta != "" else 0
    demow = c.text_width("DEMO", "4x5") + 4 + 3 if demo else 0
    room = RZ_R - EDGEL + 1 - metaw - demow - 4
    text = clip(c, label, "4x5", room)
    ink = "black" if luma(chip_color) > 150 else "white"
    w = c.text_width(text, "4x5") + 4
    c.badge(text, EDGEL, 0, color = ink, bg = chip_color, font = "4x5")
    if demo:
        c.badge("DEMO", EDGEL + w + 3, 0, color = "black", bg = AMBER, font = "4x5")
    if meta != "":
        c.text(meta, RZ_R, 1, font = "4x5", color = meta_color, align = "right")

def route_block(c, origin, dest, ymd, cabin, adults):
    c.text(origin, ROUTEX, 9, font = "8x10", color = INK)
    ax = ROUTEX + c.text_width(origin, "8x10") + 3
    c.sprite(ARROW, ax, 12, color = SKY)
    c.text(dest, ax + 12, 9, font = "8x10", color = INK)
    when = MONTH[ymd[1]] + " " + str(ymd[2]) if ymd != None else "NO DATE"
    # "MAR 14  PREMIUM" is 67 px; the block has 72 before the fare column.
    c.text(clip(c, when + "  " + cabin_label(cabin), "4x5", ROUTEW), ROUTEX, 21,
           font = "4x5", color = DIM)
    c.text(str(adults) + (" ADULT" if adults == 1 else " ADULTS"), ROUTEX, 27,
           font = "4x5", color = DIM)

def fare_hero(c, fare, color):
    text = "$" + str(int(fare))
    ft = fit(c, text, ["16x20", "10x16", "8x10", "6x8"], FAREW)
    h = FONTH[ft[0]]
    c.text(ft[1], RZ_R, 8 + (24 - h) // 2, font = ft[0], color = color, align = "right")

def card(c, chip, head, sub, head_color):
    """The two-line answer for anything that is not a fare: what, then what
    to do. The plane and a gray chip stay so the app still says what it is."""
    scene(c)
    chip_row(c, chip, OFFLINE, False, "", DIM)
    mid = (ROUTEX + RZ_R) // 2
    c.text(head, mid, 11, font = "5x7", color = head_color, align = "center")
    c.text(sub, mid, 23, font = "4x5", color = DIM, align = "center")

CARDS = {
    "offline": ["SERPAPI UNREACHABLE", "FARE RETURNS NEXT REFRESH", AMBER],
    "badkey": ["KEY REJECTED", "CHECK YOUR SERPAPI KEY", RED],
    "limit": ["MONTHLY LIMIT HIT", "FREE PLAN IS 250 SEARCHES", RED],
    "badrequest": ["SEARCH REFUSED", "CHECK AIRPORTS AND DATE", AMBER],
    "nofare": ["NO FARES FOUND", "NOTHING LISTED FOR THAT DAY", AMBER],
}

def fare(c, ctx):
    c.fill("black")
    apikey = str(ctx.inputs.get("apikey", "")).strip()
    fp = flight_parts(ctx.inputs.get("flightnumber", ""))
    origin = only(ctx.inputs.get("origin", ""), LETTERS)[:3]
    dest = only(ctx.inputs.get("destination", ""), LETTERS)[:3]
    ymd = parse_date(ctx.inputs.get("departuredate", ""))
    adults = int(only(ctx.inputs.get("passengers", "1"), "0123456789") or "1")
    cabin = str(ctx.inputs.get("travelclass", "ECONOMY")).strip().upper()
    dbg = str(ctx.inputs.get("_debugstate", "")).strip().lower()

    # Demo: no key yet. Whatever settings exist are honored; the rest is a
    # believable sample, labelled DEMO in the chip row.
    if apikey == "" or dbg == "demo":
        code = fp[0] if fp[0] != "" else "B6"
        num = fp[1] if fp[1] != "" else "1234"
        origin = origin if len(origin) == 3 else "MCO"
        dest = dest if len(dest) == 3 else "JFK"
        ymd = ymd if ymd != None else [2026, 10, 1]
        draw_fare(c, code, num, origin, dest, ymd, cabin, adults, 249, "TYPICAL",
                  True, True)
        return

    if dbg in CARDS:
        card(c, "FLIGHT FARE", CARDS[dbg][0], CARDS[dbg][1], CARDS[dbg][2])
        return

    # Every setting the search needs, each with its own line.
    if fp[0] == "":
        card(c, "FLIGHT FARE", "ADD A FLIGHT NUMBER", "LIKE B6 1234 IN SETTINGS", AMBER)
        return
    if len(origin) != 3:
        card(c, "FLIGHT FARE", "ADD THE ORIGIN AIRPORT", "3-LETTER CODE LIKE MCO", AMBER)
        return
    if len(dest) != 3:
        card(c, "FLIGHT FARE", "ADD THE DESTINATION", "3-LETTER CODE LIKE JFK", AMBER)
        return
    if ymd == None:
        card(c, "FLIGHT FARE", "PICK A DEPARTURE DATE", "IN THE APP SETTINGS", AMBER)
        return
    # A flight that has already left has no fare to track. Say so without
    # spending a search on it: this is the case that would otherwise burn
    # the whole monthly quota on a forgotten setting.
    if days_from_civil(ymd[0], ymd[1], ymd[2]) < ctx.now.unix // 86400 or dbg == "departed":
        card(c, "FLIGHT FARE", "THAT FLIGHT HAS LEFT", "PICK A NEW DATE IN SETTINGS", DIM)
        return

    if dbg in ["low", "high", "route"]:
        res = ["ok", 189 if dbg == "low" else 412, "LOW" if dbg == "low" else "HIGH",
               dbg != "route"]
    else:
        res = lookup(apikey, fp[0], fp[1], origin, dest, ymd, adults, cabin)
    if res[0] != "ok":
        card(c, "FLIGHT FARE", CARDS[res[0]][0], CARDS[res[0]][1], CARDS[res[0]][2])
        return
    draw_fare(c, fp[0], fp[1], origin, dest, ymd, cabin, adults, res[1], res[2],
              res[3], False)

def draw_fare(c, code, num, origin, dest, ymd, cabin, adults, fare, level, exact, demo):
    scene(c)
    al = AIRLINES[code] if code in AIRLINES else [code, "#E8ECF4"]
    meta = level_meta(level)
    if not exact:
        # Google did not list this flight number: the fare shown is the
        # cheapest on the route that day, and the row says so instead of
        # pretending it is the flight's own.
        meta = ["LOWEST ON ROUTE", DIM]
    chip_row(c, al[0] + " " + num, al[1], demo, meta[0], meta[1])
    route_block(c, origin, dest, ymd, cabin, adults)
    color = INK
    if level == "LOW":
        color = GREEN
    elif level == "HIGH":
        color = RED
    fare_hero(c, fare, color)
