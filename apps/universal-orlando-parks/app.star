# Universal Orlando Parks for a Glance SCROLL panel (192x32).
#
# DESIGN. A splash page opens the app the way the resort opens: the globe,
# the name, and the four parks in their own colors. Then one page per park.
# Each park page is a marquee: a colored chip with the park's name across the
# top, its landmark in pixel art on the left (the globe, the Pharos
# lighthouse, the Chronos portal, Krakatau), the crowd word in the middle as
# the hero with a five-block meter under it, and on the right the three
# longest standby waits, each wearing its minutes in a pill colored by how
# much it hurts. The chip row also says when the gates close and, in the
# fall, when Halloween Horror Nights starts. After hours the crowd word
# becomes CLOSED with the next opening under it, and the wait rows become the
# hours card: today, tomorrow, and Early Park Admission or tonight's event.
# With no network at all, the chip goes gray, the art stays (it is drawn
# from code), and an amber card says so.
#
# Data: api.themeparks.wiki live standby queues + schedule, per park. All four
# parks keep Eastern time, worked out here with no network call. Two fetches
# per park, four parks: exactly the eight-request budget, which is why the
# splash page fetches nothing.

API = "https://api.themeparks.wiki/v1/entity/"
TTL = 900                 # matches refresh: in the manifest

PARKS = {
    "studios": {
        "id": "eb3f4560-2383-4a36-9152-6b3e5ed6bc57",
        "name": "UNIVERSAL STUDIOS", "short": "STUDIOS",
        # `short` is the splash chip; the full name is the page chip.
        "color": "#2F80FF", "art": "GLOBE",
    },
    "islands": {
        "id": "267615cc-8943-4c2a-ae2c-5da728ca591f",
        "name": "ISLANDS OF ADVENTURE", "short": "ISLANDS",
        "color": "#FF8A1E", "art": "LIGHTHOUSE",
    },
    "epic": {
        "id": "12dbb85b-265f-44e6-bccf-f1faa17211fc",
        "name": "EPIC UNIVERSE", "short": "EPIC",
        "color": "#A86BFF", "art": "PORTAL",
    },
    "volcano_bay": {
        "id": "fe78a026-b91b-470c-b906-9d2266b692da",
        "name": "VOLCANO BAY", "short": "VOLCANO BAY",
        "color": "#22D3D3", "art": "VOLCANO",
    },
}
ORDER = ["studios", "islands", "epic", "volcano_bay"]

INK = "#F4F7FF"           # primary text
DIM = "#6E7A94"           # labels
STRUCT = "darkgray"       # the one divider
OFFLINE = "#3C4043"       # the chip when there is no data
HHN = "#FF6A00"           # Halloween Horror Nights

# ---- geometry ----------------------------------------------------------------
# The app keeps 6 px clear at both outer edges (x 6..185) so it reads as its
# own unit between the apps around it. Chip row y 0..6, content band y 8..31.
# Art x 6..31, the crowd column x 35..87 (PACKED and CLOSED are 53 px at
# 8x10), a divider at x 90, and the wait rows x 94..185 with their pills
# right-aligned at x 185. A 120M pill is 23 px, which leaves a name 66 px:
# every nickname below fits that, so a 3-digit wait never clips a name.
EDGEL = 6
ARTX = 6
ARTY = 8
MX = 35
DIVX = 90
RZ_L = 94
RZ_R = 185

# ---- pixel art -----------------------------------------------------------------
GLOBE_LEG = {"B": "#1B5FD6", "b": "#0F3FA0", "H": "#4A8CFF", "W": "#E8F0FF",
             "w": "#B8C8E8", "G": "#FFC63A", "g": "#8C6A1A"}

GLOBE = """
..........HHHBB...........
........HHHHBBBBB.........
......HHHHHBBBBWWWB.......
.....WWWWWBBBBWWWWWBggggg.
....HHWWWWWWBBBWWWWWB...G.
....HHHWWWWBBBBWWWWBB...G.
...HHHHBWWWBBBBBWWWWWB.GG.
...HHHBBBWWWBBBBWWWWWWGG..
..HHHBBBBBWWWBBBBWWWWBG...
..HHBBBBBBBWWBBBBWWWGGb...
..HBBBBBBBBWWBBBBBWGGbb...
..BBBBBBBBBBWWBBBBGGbbb...
..BBBBBBBBBBWWBBGGGwbbb...
.ggBBBWWBBBBBWGGGbbwbb....
gg.BBBWWWBBBGGGBbbbbbb....
g...BBBWWBGGGBBbbbbbb.....
G...BBBGGGGBBBbbbbbbb.....
GGGGGGGGBBBBBbbbbbbb......
......BBBBBBbbbbbbb.......
........BBBbbbbbb.........
..........bbbbb...........
"""

GLOBE_BIG = """
............HHHHHBBBB.............
..........HHHHHHBBBBBBB...........
........HHHHHHHBBBBBWWWWB.........
.......WWWWWWHBBBBWWWWWWWBgggggg..
......HWWWWWWWWWBBWWWWWWWWW....gG.
.....HHHWWWWWWWWBBBBWWWWWWWB....G.
.....HHHHWWWWWWBBBBBWWWWWBBB...GG.
....HHHHHHBWWWWBBBBBBWWWWWWWB..G..
....HHHHHBBWWWWWBBBBBWWWWWWWW.GG..
....HHHHBBBBWWWWBBBBBWWWWWWWWGG...
...HHHHBBBBBBWWWWBBBBBWWWWWWGG....
...HHHBBBBBBBBBWWBBBBBWWWWWGGb....
...HHBBBBBBBBBBWWBBBBBWWWWGGbb....
...HBBBBBBBBBBBWWBBBBBBBWGGwbb....
...BBBBBBBBBBBBBWWWBBBBGGGwbbb....
...BBBBBBBBBBBBBWWWBBBGGbwwbbb....
..ggBBBBWWWBBBBBBWWBGGGbbwwbb.....
.gg.BBBBWWWBBBBBBWGGGBbbbwwbb.....
.g..BBBBWWWWBBBBGGGBBbbbbbbbb.....
gg...BBBBWWWBBGGGBBBbbbbbbbb......
g....BBBBBBGGGGBBBBbbbbbbbbb......
GG....BBGGGGBBBBBBbbbbbbbbb.......
.GGGGGGGGBBBBBBBBbbbbbbbbb........
........BBBBBBBBbbbbbbbbb.........
..........BBBBBbbbbbbbb...........
............BBbbbbbbb.............
"""

# The Pharos Lighthouse: Islands of Adventure's icon, lit, on its rock.
LIGHTHOUSE_LEG = {"S": "#C9A96E", "s": "#8C6E3C", "R": "#E03A2E", "C": "#8FE9FF",
                  "L": "#FFE066", "r": "#B08A20", "K": "#5A4A3A", "W": "#2D8CE8",
                  "w": "#BFE9FF", "D": "#3A2A1A"}
LIGHTHOUSE = """
............RR............
...........RRRR...........
..........RRRRRR..........
.........SSSSSSSS.........
..r.......CLLLLC.......r..
...r......CLLLLC......r...
....r.....CLLLLC.....r....
.........SSSSSSSS.........
..........SSSSss..........
..........SSSSss..........
..........SSSSss..........
.........SSSSSsss.........
.........SSSSSsss.........
.........SSSSSsss.........
........SSSSSSssss........
........SSSSSSssss........
........SSSSSSssss........
.......SSSSSDDsssss.......
.......SSSSSDDsssss.......
......SSSSSSDDssssss......
....KKKKKKKKKKKKKKKKKK....
wWWWWwWWWWWWWWWWWwWWWWWwWW
WWWWWWWWWWWWWWWWWWWWWWWWWW
"""

# The Chronos: Epic Universe's portal gate, a bronze ring around a glow.
PORTAL_LEG = {"O": "#D9A441", "o": "#8C6A2A", "P": "#7A3CFF", "p": "#3A1A80",
              "Q": "#B08CFF", "W": "white", "S": "#5A4A5A"}
PORTAL = """
............W.............
...........WWW............
........OOOOWOOOO.........
......OOOooooooOOO........
.....OOoo.......ooOO......
....OOo...........oOO.....
...OOo....ppppp....oOO....
...Oo....ppPPPpp....oO....
..OOo...ppPPQPPpp...oOO...
..Oo....pPPQWQPPp....oO...
..Oo....pPPQQQPPp....oO...
..Oo....pPPPQPPPp....oO...
..OOo...ppPPPPPpp...oOO...
...Oo....ppPPPpp....oO....
...OOo....ppppp....oOO....
....OOo...........oOO.....
.....OOoo.......ooOO......
......OOOooo.oooOOO.......
........OOOOoOOOO.........
...........SSS............
..........SSSSS...........
.......SSSSSSSSSSS........
......SSSSSSSSSSSSS.......
"""

# Krakatau: Volcano Bay's volcano, a waterfall down its face and lava down
# its shoulder, standing in the wave pool.
VOLCANO_LEG = {"K": "#6E5040", "k": "#4A3528", "R": "#FF3B1A", "O": "#FFA020",
               "Y": "#FFE066", "W": "#22B8E8", "w": "#C8F4FF", "C": "#7FE3FF",
               "S": "#8A8A96"}
VOLCANO = """
..........SS..............
.........S..S.............
..........YOY.............
.........KORRK............
.........KKRRKK...........
........KKKRKKKK..........
........KKKRKKKKK.........
.......KKKKRKKKKKK........
.......KKKKRRKKkKKK.......
......KKKKKCRKKkkKKK......
......KKKKKCKRKKkkKKK.....
.....KKKKKKCKKRKkkkKKK....
.....KKKKKKCKKKRkkkKKKK...
....KKKKKKKCKKKKRkkkkKKK..
....KKKKKKKCKKKKKRkkkkKKK.
...KKKKKKKKCKKKKKKkkkkkKKK
...KKKKKKKCCKKKKKKKkkkkkKK
..KKKKKKKKCCKKKKKKKKkkkkkK
.KKKKKKKKKCCKKKKKKKKKkkkkk
KKKKKKKKKCCCKKKKKKKKKKkkkk
wwwWWWWWwwwwWWWWWWwwWWWWWw
WWWWWWWWWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWWWWWWWWW
"""

def draw_art(c, kind):
    if kind == "GLOBE":
        c.sprite(GLOBE, ARTX, ARTY + 1, legend = GLOBE_LEG)
    elif kind == "LIGHTHOUSE":
        c.sprite(LIGHTHOUSE, ARTX, ARTY, legend = LIGHTHOUSE_LEG)
    elif kind == "PORTAL":
        c.sprite(PORTAL, ARTX, ARTY, legend = PORTAL_LEG)
    else:
        c.sprite(VOLCANO, ARTX, ARTY, legend = VOLCANO_LEG)

# ---- text kit --------------------------------------------------------------------
def clip(c, text, font, maxw):
    """Longest prefix that fits. Nothing in the API clips, so every feed
    string passes through here before it is drawn."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def clip_words(c, text, font, maxw):
    """clip(), backed up to the last whole word unless that costs > 30%."""
    t = clip(c, text, font, maxw)
    if t == str(text):
        return t
    sp = t.rfind(" ")
    if sp > 0 and sp * 10 >= len(t) * 7:
        return t[:sp]
    return t

KEEP = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -&.'!:"

def clean_name(name):
    """Uppercase, trademark glyphs and anything the fonts lack dropped,
    runs of spaces collapsed."""
    out = ""
    for ch in str(name).upper().elems():
        if KEEP.find(ch) >= 0:
            out = out + ch
    parts = []
    for p in out.split(" "):
        if p != "":
            parts.append(p)
    return " ".join(parts)

# The names people actually use, sized for the wait rows: the longest a name
# can be is 67 px at 4x5 when the pill beside it says 120M. Needles are
# matched against the cleaned feed name, first hit wins, so the water park's
# "Honu of Honu ika Moana" and "ika Moana of Honu ika Moana" each get their
# own word. Anything unmatched is clipped at a word boundary instead.
NICKS = [
    ["GRINGOTTS", "GRINGOTTS"], ["MUMMY", "THE MUMMY"],
    ["MINION MAYHEM", "MINION MAYHEM"], ["VILLAIN", "MINION BLAST"],
    ["MEN IN BLACK", "MEN IN BLACK"], ["TRANSFORMERS", "TRANSFORMERS"],
    ["SIMPSONS", "THE SIMPSONS"], ["FALLON", "JIMMY FALLON"],
    ["E.T.", "ET ADVENTURE"], ["HOGWARTS", "HOGWARTS TRAIN"],
    ["TROLLS", "TROLLS COASTER"], ["KANG", "TWIRL N HURL"],
    ["HAGRID", "HAGRIDS BIKES"], ["VELOCI", "VELOCICOASTER"],
    ["FORBIDDEN", "FORBIDDEN JRNY"], ["HULK", "HULK COASTER"],
    ["SPIDER", "SPIDER-MAN"], ["KONG", "REIGN OF KONG"],
    ["RIVER ADVENTURE", "JURASSIC RIVER"], ["HIPPOGRIFF", "HIPPOGRIFF"],
    ["RIPSAW", "RIPSAW FALLS"], ["BILGE", "POPEYE BARGES"],
    ["DOOM", "DOOM FEARFALL"], ["STORM FORCE", "STORM FORCE"],
    ["CAT IN THE HAT", "CAT IN THE HAT"], ["TROLLEY", "SEUSS TROLLEY"],
    ["CARO-SEUSS", "CARO-SEUSS-EL"], ["ONE FISH", "ONE FISH"],
    ["PTERANODON", "PTERANODON"], ["MINISTRY", "THE MINISTRY"],
    ["MONSTERS", "MONSTERS"], ["MARIO KART", "MARIO KART"],
    ["STARDUST", "STARDUST RACER"], ["WEREWOLF", "WEREWOLF"],
    ["HICCUP", "WING GLIDERS"], ["DRAGON RACER", "DRAGON RACERS"],
    ["MINE-CART", "MINE-CART"], ["YOSHI", "YOSHI"],
    ["BOWSER JR", "BOWSER JR"], ["FYRE", "FYRE DRILL"],
    ["CONSTELLATION", "CONSTELLATION"],
    ["KRAKATAU", "AQUA COASTER"], ["KO'OKIRI", "KOOKIRI PLUNGE"],
    ["PUNGA", "PUNGA RACERS"], ["IKA MOANA OF", "IKA MOANA"],
    ["HONU", "HONU"], ["MAKU OF", "MAKU"], ["PUIHI OF", "PUIHI"],
    ["OHYAH OF", "OHYAH"], ["OHNO OF", "OHNO"], ["KALA", "KALA TAI NUI"],
    ["TANIWHA", "TANIWHA TUBES"], ["TEAWA", "TEAWA RIVER"],
    ["KOPIKO", "KOPIKO WAI"], ["WATURI", "WATURI BEACH"],
    ["RUNAMUKKA", "RUNAMUKKA"], ["TOT TIKI", "TOT TIKI REEF"],
    ["PUKA ULI", "PUKA ULI"],
]

def ride_name(c, raw, room):
    t = clean_name(raw)
    for n in NICKS:
        if t.find(n[0]) >= 0:
            t = n[1]
            break
    if c.text_width(t, "4x5") <= room:
        return t
    t = clip_words(c, t, "4x5", room)
    for _ in range(3):
        if len(t) > 0 and t[len(t) - 1] in [":", "-", ",", ".", "&", " ", "'"]:
            t = t[:len(t) - 1]
        else:
            break
    return t

def get(obj, key, fallback = None):
    if obj == None or type(obj) != "dict":
        return fallback
    v = obj.get(key, fallback)
    return fallback if v == None else v

def lst(obj, key):
    v = get(obj, key, [])
    return v if type(v) == "list" else []

# ---- Eastern time, no network -----------------------------------------------------
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
    """Day of the month of the nth Sunday. Day 0 (1970-01-01) was a Thursday."""
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
    """Minutes past midnight in the stamp's own (park-local) clock."""
    t = str(value)
    if len(t) < 16:
        return -1
    return int(t[11:13]) * 60 + int(t[14:16])

def clock(value):
    """themeparks.wiki hands back park-local stamps, so the hour is read
    straight out of the string: 10A, 6:30P."""
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

def span(entry):
    if entry == None:
        return ""
    a = clock(get(entry, "openingTime"))
    b = clock(get(entry, "closingTime"))
    if a == "" or b == "":
        return ""
    return a + "-" + b

# ---- feed --------------------------------------------------------------------------
def fetch(path):
    r = http.get(API + path, headers = {"accept": "application/json"},
                 ttl_seconds = TTL)
    if r["status_code"] != 200:
        return None
    return r["json"]

def find_entry(schedule, key, kind):
    for e in schedule:
        if get(e, "date", "") == key and get(e, "type", "") == kind:
            return e
    return None

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

def read_park(ctx, park):
    """Everything a page draws, display-ready, or {"online": False}."""
    dbg = str(ctx.inputs.get("_debugstate", "")).strip().lower()
    if dbg != "":
        return demo_state(park, dbg)

    live = fetch(park["id"] + "/live")
    sched = fetch(park["id"] + "/schedule")
    if live == None and sched == None:
        return {"online": False}
    rows = lst(live, "liveData")
    entries = lst(sched, "schedule")

    now = eastern_minutes(ctx.now.unix)
    today = civil_from_days(now // 1440)
    tmrw = civil_from_days(now // 1440 + 1)
    nowmin = now % 1440
    t_op = find_entry(entries, date_key(today), "OPERATING")
    m_op = find_entry(entries, date_key(tmrw), "OPERATING")
    extra = find_entry(entries, date_key(today), "EXTRA_HOURS")
    event = find_entry(entries, date_key(today), "TICKETED_EVENT")

    operating = 0
    waits = []
    total = 0
    for e in rows:
        if get(e, "entityType", "") != "ATTRACTION":
            continue
        if get(e, "status", "") != "OPERATING":
            continue
        operating += 1
        w = standby(e)
        if w == None:
            continue
        waits.append([w, get(e, "name", "")])
        total += w
    waits = sorted(waits, key = lambda r: -r[0])

    ev = None
    if event != None:
        desc = str(get(event, "description", "")).upper()
        tag = "HHN" if desc.find("HALLOWEEN") >= 0 else "EVENT"
        ev = [tag, clock(get(event, "openingTime")), clock(get(event, "closingTime")),
              iso_minutes(get(event, "openingTime"))]

    # What the chip row says on the right: when this stops. During the
    # event the park's own closing has passed, so the event's is the one.
    closing = clock(get(t_op, "closingTime")) if t_op != None else ""
    if ev != None and ev[3] >= 0 and nowmin >= ev[3]:
        closing = ev[0] + " TIL " + ev[2]
    elif closing != "":
        closing = "OPEN TIL " + closing

    opens = ""
    if t_op != None and nowmin < iso_minutes(get(t_op, "openingTime")):
        opens = clock(get(t_op, "openingTime"))
    elif m_op != None:
        opens = clock(get(m_op, "openingTime"))

    return {
        "online": True,
        "open": operating >= 3,
        "waits": waits,
        "avg": (total // len(waits)) if len(waits) > 0 else -1,
        "closing": closing,
        "opens": opens,
        "today": span(t_op),
        "tmrw": span(m_op),
        "early": clock(get(extra, "openingTime")) if extra != None else "",
        "event": ev,
    }

# Sample states for previewing every screen while the parks are closed:
# _debugstate = open | quiet | closed | offline (hidden, undeclared input).
DEMO_WAITS = {
    "studios": [[75, "GRINGOTTS"], [45, "THE MUMMY"], [40, "MINION MAYHEM"],
                [35, "TRANSFORMERS"], [30, "MEN IN BLACK"], [25, "THE SIMPSONS"],
                [20, "ET ADVENTURE"], [15, "JIMMY FALLON"]],
    "islands": [[120, "HAGRIDS BIKES"], [90, "VELOCICOASTER"], [60, "FORBIDDEN JRNY"],
                [45, "HULK COASTER"], [35, "SPIDER-MAN"], [30, "REIGN OF KONG"],
                [25, "JURASSIC RIVER"], [20, "RIPSAW FALLS"]],
    "epic": [[150, "THE MINISTRY"], [90, "MONSTERS"], [75, "MARIO KART"],
             [60, "STARDUST RACER"], [55, "MINE-CART"], [45, "WEREWOLF"],
             [35, "WING GLIDERS"], [30, "DRAGON RACERS"], [25, "YOSHI"],
             [10, "FYRE DRILL"]],
    "volcano_bay": [[45, "AQUA COASTER"], [30, "KOOKIRI PLUNGE"], [25, "HONU"],
                    [20, "PUNGA RACERS"], [15, "MAKU"], [10, "OHYAH"]],
}

def demo_state(park, dbg):
    if dbg == "offline":
        return {"online": False}
    waits = DEMO_WAITS[park_key(park)]
    total = 0
    for w in waits:
        total += w[0]
    st = {"online": True, "open": True, "waits": waits, "avg": total // len(waits),
          "closing": "OPEN TIL 9P", "opens": "9A", "today": "9A-9P",
          "tmrw": "9A-8P", "early": "8A", "event": None}
    if park["art"] == "GLOBE":
        st["closing"] = "OPEN TIL 5P"
        st["today"] = "10A-5P"
        st["event"] = ["HHN", "6:30P", "2A", 1110]
    if dbg == "quiet":
        st["waits"] = []
        st["avg"] = -1
    elif dbg == "closed":
        st["open"] = False
        st["waits"] = []
        st["avg"] = -1
        st["closing"] = ""
    return st

def park_key(park):
    for k in ORDER:
        if PARKS[k]["id"] == park["id"]:
            return k
    return "studios"

# ---- crowd bands --------------------------------------------------------------------
def crowd(avg):
    """[level 1-5, WORD, color] from the average posted standby wait across
    the park. An average, not the top two: Hagrid's and VelociCoaster post
    an hour on the quietest day, so the peak alone says nothing about the
    rest of the park."""
    if avg <= 15:
        return [1, "LIGHT", "green"]
    if avg <= 25:
        return [2, "MILD", "#8FD14F"]
    if avg <= 40:
        return [3, "BUSY", "amber"]
    if avg <= 55:
        return [4, "HEAVY", "orange"]
    return [5, "PACKED", "red"]

def wait_color(w):
    """Per-ride minutes band: what one wait feels like."""
    if w < 30:
        return "green"
    if w < 60:
        return "amber"
    if w < 90:
        return "orange"
    return "red"

# ---- drawing ------------------------------------------------------------------------
def chip_row(c, park, chip_color, event, meta, meta_color):
    """Park chip at the left, the event chip (if any) beside it, and the
    closing time right-aligned at the app's edge."""
    w = c.text_width(park["name"], "4x5") + 4
    c.badge(park["name"], EDGEL, 0, color = "black", bg = chip_color, font = "4x5")
    if event != None and event[1] != "":
        c.badge(event[0] + " " + event[1], EDGEL + w + 3, 0, color = "black",
                bg = HHN, font = "4x5")
    if meta != "":
        c.text(meta, RZ_R, 1, font = "4x5", color = meta_color, align = "right")

def middle(c, label, word, word_color, sub, sub_color, level, level_color):
    c.text(label, MX, 8, font = "4x5", color = DIM)
    # 8x10, not 8x12: that face's I is a solid 6 px block, so MILD and LIGHT
    # came out as M-block-LD. PACKED and CLOSED are 53 px here too.
    c.text(word, MX, 15, font = "8x10", color = word_color)
    if level > 0:
        # five blocks, 9 px each with 2 px gaps: 33..85
        for i in range(5):
            x0 = MX + i * 11
            c.rect(x0, 27, x0 + 8, 29, fill = level_color if i < level else "#252525")
    elif sub != "":
        c.text(sub, MX, 27, font = "4x5", color = sub_color)

def wait_rows(c, waits):
    """Three rows, longest first. The pill is measured first; the name gets
    what the pill leaves and is nicknamed or clipped into it."""
    y = 8
    for row in waits[:3]:
        mins = str(row[0]) + "M"
        pw = c.text_width(mins, "4x5") + 4
        px = RZ_R - pw + 1
        col = wait_color(row[0])
        c.badge(mins, px, y, color = "white" if col == "red" else "black",
                bg = col, font = "4x5")
        c.text(ride_name(c, row[1], px - 3 - RZ_L), RZ_L, y + 1, font = "4x5",
               color = INK)
        y += 8

def hours_card(c, st, accent):
    rows = []
    if st["today"] != "":
        rows.append(["TODAY", st["today"], INK])
    if st["tmrw"] != "":
        rows.append(["TMRW", st["tmrw"], "amber"])
    ev = st["event"]
    if ev != None and ev[1] != "" and ev[2] != "":
        rows.append([ev[0] + " TONIGHT", ev[1] + "-" + ev[2], HHN])
    elif st["early"] != "":
        rows.append(["EARLY ENTRY", st["early"], accent])
    if len(rows) == 0:
        c.text("NO HOURS POSTED", (RZ_L + RZ_R) // 2, 14, font = "4x5", color = DIM,
               align = "center")
        return
    y = 9
    for r in rows[:3]:
        c.text(r[1], RZ_R, y, font = "4x5", color = r[2], align = "right")
        c.text(r[0], RZ_L, y, font = "4x5", color = DIM)
        y += 8

def offline_card(c):
    mid = (MX + RZ_R) // 2
    c.text("PARKS UNREACHABLE", mid, 11, font = "5x7", color = "amber",
           align = "center")
    c.text("WAITS RETURN NEXT REFRESH", mid, 23, font = "4x5", color = DIM,
           align = "center")

def park_page(c, ctx, key):
    park = PARKS[key]
    c.fill("black")
    # Identity never waits on the network: art first, chip next.
    draw_art(c, park["art"])
    st = read_park(ctx, park)
    if not st["online"]:
        chip_row(c, park, OFFLINE, None, "", DIM)
        offline_card(c)
        return
    c.vline(DIVX, 8, 23, STRUCT)

    if st["open"] and len(st["waits"]) >= 2:
        lvl = crowd(st["avg"])
        chip_row(c, park, park["color"], st["event"], st["closing"], "green")
        middle(c, "CROWDS", lvl[1], lvl[2], "", "", lvl[0], lvl[2])
        wait_rows(c, st["waits"])
    elif st["open"]:
        chip_row(c, park, park["color"], st["event"], st["closing"], "green")
        middle(c, "PARK", "OPEN", "green", "NO WAITS YET", DIM, 0, "")
        hours_card(c, st, park["color"])
    else:
        chip_row(c, park, park["color"], st["event"], "CLOSED", "red")
        sub = ("OPENS " + st["opens"]) if st["opens"] != "" else ""
        middle(c, "PARK", "CLOSED", "red", sub, "amber", 0, "")
        hours_card(c, st, park["color"])

# ---- pages -----------------------------------------------------------------------------
def home(c, ctx):
    """The splash: the globe, the name, and the four parks in their colors.
    Fetches nothing, so the park pages keep the whole request budget."""
    c.fill("black")
    # The chip row lists the four parks in their colors, spread across the
    # width: the legend for the pages that follow. Chips are measured and the
    # slack split into the three gaps, so the last one lands on the edge.
    total = 0
    for k in ORDER:
        total += c.text_width(PARKS[k]["short"], "4x5") + 4
    gap = (RZ_R - EDGEL + 1 - total) // 3
    x = EDGEL
    for k in ORDER:
        c.badge(PARKS[k]["short"], x, 0, color = "black", bg = PARKS[k]["color"],
                font = "4x5")
        x += c.text_width(PARKS[k]["short"], "4x5") + 4 + gap
    c.sprite(GLOBE_BIG, EDGEL, 6, legend = GLOBE_LEG)
    c.text("UNIVERSAL", 46, 8, font = "10x16", color = INK)
    c.text("ORLANDO RESORT", 46, 25, font = "5x7", color = DIM)
    c.text("LIVE WAITS", RZ_R, 26, font = "4x5", color = DIM, align = "right")

def studios(c, ctx):
    park_page(c, ctx, "studios")

def islands(c, ctx):
    park_page(c, ctx, "islands")

def epic(c, ctx):
    park_page(c, ctx, "epic")

def volcano_bay(c, ctx):
    park_page(c, ctx, "volcano_bay")
