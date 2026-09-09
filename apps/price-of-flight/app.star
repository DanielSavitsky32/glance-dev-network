BG = "#05070B"

BLUE = "#2E8BFF"
LIGHT_BLUE = "#63B4FF"
GREEN = "#42FF78"
GRAY = "#73798D"
WHITE = "#FFFFFF"

AMBER = "#F0B44D"
RED = "#FF4D5E"

DARK_BLUE = "#17304C"
DARK_GREEN = "#173923"


def clean_text(value):
    return str(value).upper()


def clean_flight(value):
    return clean_text(value).replace(" ", "").replace("-", "")


def carrier_code(flight):
    value = clean_flight(flight)

    if len(value) >= 2:
        return value[:2]

    return "??"


def display_flight(value):
    value = clean_flight(value)

    if len(value) > 2:
        return value[:2] + " " + value[2:]

    return value


def short_date(value):
    value = str(value)

    if len(value) >= 10:
        return value[5:10].upper()

    return value.upper()


def class_api(value):
    value = clean_text(value)

    if value == "PREMIUM":
        return "2"

    if value == "BUSINESS":
        return "3"

    if value == "FIRST":
        return "4"

    return "1"


def class_short(value):
    value = clean_text(value)

    if value == "PREMIUM":
        return "PREM"

    if value == "BUSINESS":
        return "BUS"

    if value == "FIRST":
        return "FIRST"

    return "ECO"


def best_font(c, value, fonts, max_width):
    value = clean_text(value)

    for font in fonts:
        if c.text_width(value, font) <= max_width:
            return font

    return fonts[len(fonts) - 1]


def draw_fit(c, value, x, y, fonts, color, max_width, align="left"):
    value = clean_text(value)
    font = best_font(c, value, fonts, max_width)

    c.text(
        value,
        x,
        y,
        font=font,
        color=color,
        align=align,
    )


def draw_airline(c, carrier):
    code = carrier.upper()

    x = 9
    y = 7

    # JETBLUE
    if code == "B6":
        c.rect(
            x,
            y,
            x + 20,
            y + 19,
            fill="#062E51",
            outline="#0085CA",
        )

        c.rect(x + 2, y + 2, x + 6, y + 6, fill="#00AEEF")
        c.rect(x + 8, y + 2, x + 12, y + 6, fill="#0072CE")
        c.rect(x + 14, y + 2, x + 18, y + 6, fill="#5BC2E7")

        c.rect(x + 2, y + 8, x + 6, y + 12, fill="#0072CE")
        c.rect(x + 8, y + 8, x + 12, y + 12, fill="#5BC2E7")
        c.rect(x + 14, y + 8, x + 18, y + 12, fill="#00AEEF")

        c.rect(x + 2, y + 14, x + 6, y + 17, fill="#5BC2E7")
        c.rect(x + 8, y + 14, x + 12, y + 17, fill="#00AEEF")
        c.rect(x + 14, y + 14, x + 18, y + 17, fill="#0072CE")


    # DELTA
    elif code == "DL":
        c.rect(
            x,
            y,
            x + 20,
            y + 19,
            fill="#11131A",
            outline="#E51937",
        )

        c.line(x + 10, y + 2, x + 3, y + 15, "#E51937")
        c.line(x + 10, y + 2, x + 17, y + 15, "#E51937")
        c.line(x + 3, y + 15, x + 17, y + 15, "#E51937")

        c.line(x + 10, y + 7, x + 7, y + 14, "#9D2235")
        c.line(x + 10, y + 7, x + 13, y + 14, "#9D2235")


    # AMERICAN
    elif code == "AA":
        c.rect(
            x,
            y,
            x + 20,
            y + 19,
            fill="#11131A",
            outline="#B8C5D4",
        )

        c.line(x + 3, y + 16, x + 10, y + 3, "#3C79B4")
        c.line(x + 6, y + 16, x + 12, y + 5, "#3C79B4")

        c.line(x + 11, y + 5, x + 17, y + 16, "#D9272E")
        c.line(x + 14, y + 3, x + 19, y + 13, "#D9272E")


    # UNITED
    elif code == "UA":
        c.rect(
            x,
            y,
            x + 20,
            y + 19,
            fill="#061B31",
            outline="#005DAA",
        )

        c.rect(
            x + 3,
            y + 3,
            x + 17,
            y + 16,
            outline="#57A5D8",
        )

        c.line(
            x + 10,
            y + 3,
            x + 10,
            y + 16,
            "#57A5D8",
        )

        c.line(
            x + 3,
            y + 9,
            x + 17,
            y + 9,
            "#57A5D8",
        )


    # SOUTHWEST
    elif code == "WN":
        c.rect(
            x,
            y,
            x + 20,
            y + 19,
            fill="#13182A",
            outline="#304CB2",
        )

        c.rect(x + 4, y + 4, x + 9, y + 8, fill="#D5152E")
        c.rect(x + 11, y + 4, x + 16, y + 8, fill="#D5152E")
        c.rect(x + 3, y + 7, x + 17, y + 10, fill="#D5152E")

        c.rect(x + 5, y + 11, x + 15, y + 12, fill="#F9B612")
        c.rect(x + 7, y + 13, x + 13, y + 14, fill="#304CB2")
        c.rect(x + 9, y + 15, x + 11, y + 16, fill="#304CB2")


    # ALASKA
    elif code == "AS":
        c.rect(
            x,
            y,
            x + 20,
            y + 19,
            fill="#052A3A",
            outline="#4AB3CF",
        )

        c.text_stroke(
            "AS".upper(),
            x + 10,
            y + 6,
            font="5x7",
            color="#8BD4E8",
            stroke="black",
            thickness=1,
            align="center",
        )


    # SPIRIT
    elif code == "NK":
        c.rect(
            x,
            y,
            x + 20,
            y + 19,
            fill="#FFE500",
            outline="#FFE500",
        )

        c.text_stroke(
            "NK".upper(),
            x + 10,
            y + 6,
            font="5x7",
            color="white",
            stroke="black",
            thickness=1,
            align="center",
        )


    # FRONTIER
    elif code == "F9":
        c.rect(
            x,
            y,
            x + 20,
            y + 19,
            fill="#073A29",
            outline="#00A651",
        )

        c.text_stroke(
            "F9".upper(),
            x + 10,
            y + 6,
            font="5x7",
            color="#58DB91",
            stroke="black",
            thickness=1,
            align="center",
        )


    # GENERIC AIRLINE
    else:
        c.rect(
            x,
            y,
            x + 20,
            y + 19,
            fill="#10243C",
            outline=BLUE,
        )

        c.text_stroke(
            code.upper(),
            x + 10,
            y + 6,
            font="5x7",
            color=WHITE,
            stroke="black",
            thickness=1,
            align="center",
        )


def draw_status(c, color, title, subtitle):
    c.fill(BG)

    c.rect(
        9,
        4,
        12,
        27,
        fill=color,
    )

    draw_fit(
        c,
        title,
        18,
        5,
        ["7x12", "6x8", "5x7"],
        color,
        101,
    )

    draw_fit(
        c,
        subtitle,
        18,
        21,
        ["5x7", "4x5"],
        GRAY,
        101,
    )


def draw_flight(
    c,
    flight,
    origin,
    destination,
    date,
    passengers,
    travelclass,
    price,
    demo,
):
    c.fill(BG)

    carrier = carrier_code(flight)

    # AIRLINE
    draw_airline(c, carrier)

    c.line(
        34,
        4,
        34,
        27,
        DARK_BLUE,
    )

    # FLIGHT NUMBER
    draw_fit(
        c,
        display_flight(flight),
        39,
        2,
        ["6x8", "5x7", "4x5"],
        BLUE,
        36,
    )

    # ROUTE
    route = origin[:3].upper() + ">" + destination[:3].upper()

    draw_fit(
        c,
        route,
        39,
        12,
        ["6x8", "5x7", "4x5"],
        LIGHT_BLUE,
        36,
    )

    # DATE / CABIN
    info = short_date(date) + " " + class_short(travelclass)

    draw_fit(
        c,
        info,
        39,
        24,
        ["4x5"],
        GRAY,
        36,
    )

    c.line(
        80,
        4,
        80,
        27,
        DARK_GREEN,
    )

    # PRICE LABEL
    if demo:
        c.rect(
            85,
            2,
            108,
            8,
            fill=AMBER,
            outline=AMBER,
        )

        c.text_stroke(
            "DEMO".upper(),
            96,
            3,
            font="4x5",
            color=WHITE,
            stroke="black",
            thickness=1,
            align="center",
        )

    else:
        label = str(passengers).upper() + "P FARE"

        draw_fit(
            c,
            label,
            85,
            2,
            ["4x5"],
            GRAY,
            35,
        )

    # PRICE HERO
    price_text = "$" + str(int(price))

    price_font = best_font(
        c,
        price_text,
        ["10x16", "7x12", "6x8", "5x7"],
        37,
    )

    c.text(
        price_text.upper(),
        120,
        12,
        font=price_font,
        color=GREEN,
        align="right",
    )


def lowest_price(data):
    best = None

    options = data.get("booking_options", [])

    for option in options:
        together = option.get("together")

        if together != None:
            price = together.get("price")

            if price != None:
                if best == None or price < best:
                    best = price

    if best == None:
        selected = data.get("selected_flights", [])

        for item in selected:
            price = item.get("price")

            if price != None:
                if best == None or price < best:
                    best = price

    return best


def fare(c, ctx):
    # SAVED API KEY
    #
    # You enter this once in the app settings.
    # Changing flight information does NOT require entering it again.
    apikey = str(
        ctx.inputs.get("apikey", "")
    )

    flight = clean_flight(
        ctx.inputs.get("flightnumber", "")
    )

    origin = clean_text(
        ctx.inputs.get("origin", "")
    )

    destination = clean_text(
        ctx.inputs.get("destination", "")
    )

    raw_date = str(
        ctx.inputs.get("departuredate", "")
    )

    passengers = str(
        ctx.inputs.get("passengers", "1")
    )

    travelclass = clean_text(
        ctx.inputs.get("travelclass", "ECONOMY")
    )

    date = raw_date[:10]


    # DEMO MODE
    if apikey == "":
        demo_flight = flight
        demo_origin = origin
        demo_destination = destination
        demo_date = date

        if demo_flight == "":
            demo_flight = "B61234"

        if demo_origin == "":
            demo_origin = "MCO"

        if demo_destination == "":
            demo_destination = "JFK"

        if demo_date == "":
            demo_date = "2026-10-01"

        draw_flight(
            c,
            demo_flight,
            demo_origin,
            demo_destination,
            demo_date,
            passengers,
            travelclass,
            249,
            True,
        )


    # MISSING FLIGHT
    elif len(flight) < 3:
        draw_status(
            c,
            AMBER,
            "NEED FLIGHT",
            "ENTER NUMBER",
        )


    # MISSING ORIGIN
    elif len(origin) < 3:
        draw_status(
            c,
            AMBER,
            "NEED ORIGIN",
            "ENTER AIRPORT",
        )


    # MISSING DESTINATION
    elif len(destination) < 3:
        draw_status(
            c,
            AMBER,
            "NEED DEST",
            "ENTER AIRPORT",
        )


    # MISSING DATE
    elif len(date) < 10:
        draw_status(
            c,
            AMBER,
            "NEED DATE",
            "SELECT DATE",
        )


    # LIVE LOOKUP
    else:
        origin_code = origin[:3]
        destination_code = destination[:3]

        selected_json = (
            "{\"outbound\":[{"
            + "\"flight_number\":\""
            + flight
            + "\","
            + "\"departure_id\":\""
            + origin_code
            + "\","
            + "\"arrival_id\":\""
            + destination_code
            + "\","
            + "\"date\":\""
            + date
            + "\""
            + "}]}"
        )

        params = {
            "engine": "google_flights",
            "type": "2",
            "hl": "en",
            "gl": "us",
            "currency": "USD",
            "adults": passengers,
            "travel_class": class_api(travelclass),
            "selected_flights_json": selected_json,
            "api_key": apikey,
        }

        resp = http.get(
            "https://serpapi.com/search.json",
            params=params,
            ttl_seconds=10800,
        )

        status = resp["status_code"]


        # NETWORK / TIMEOUT
        if status == 0:
            draw_status(
                c,
                RED,
                "API TIMEOUT",
                "TRY NEXT REFRESH",
            )


        # INVALID API KEY
        elif status == 401 or status == 403:
            draw_status(
                c,
                RED,
                "BAD API KEY",
                "CHECK SERPAPI",
            )


        # API QUOTA
        elif status == 429:
            draw_status(
                c,
                RED,
                "API LIMIT",
                "CHECK PLAN",
            )


        # BAD REQUEST
        elif status == 400:
            draw_status(
                c,
                RED,
                "BAD FLIGHT",
                "CHECK DETAILS",
            )


        # OTHER HTTP ERROR
        elif status != 200:
            draw_status(
                c,
                RED,
                "HTTP " + str(status),
                "SERPAPI ERROR",
            )


        # SUCCESS
        else:
            data = resp["json"]

            if data == None:
                draw_status(
                    c,
                    RED,
                    "NO DATA",
                    "TRY AGAIN",
                )

            elif data.get("error", "") != "":
                draw_status(
                    c,
                    RED,
                    "FARE ERROR",
                    "CHECK FLIGHT",
                )

            else:
                price = lowest_price(data)

                if price == None:
                    draw_status(
                        c,
                        AMBER,
                        "NO FARE",
                        "CHECK FLIGHT",
                    )

                else:
                    draw_flight(
                        c,
                        flight,
                        origin_code,
                        destination_code,
                        date,
                        passengers,
                        travelclass,
                        price,
                        False,
                    )