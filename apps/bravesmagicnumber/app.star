def get_braves_magic_number():
    resp = http.get(
        "https://statsapi.mlb.com/api/v1/standings",
        params = {
            "leagueId": "104",
            "season": "2026",
            "standingsTypes": "regularSeason",
        },
        ttl_seconds = 900,
    )

    # API unavailable or invalid JSON
    if resp["status_code"] != 200 or resp["json"] == None:
        return None

    data = resp["json"]

    # Find the NL East standings record
    for record in data.get("records", []):
        division = record.get("division", {})

        if division.get("id") == 204:
            # Find the Braves within the NL East
            for team_record in record.get("teamRecords", []):
                team = team_record.get("team", {})

                if team.get("id") == 144:
                    return team_record.get("magicNumber", None)

    return None


def main(c, ctx):
    c.fill("black")

    c.text_center(
        "BRAVES MAGIC NUMBER",
        2,
        font = "6x8",
        color = "red",
    )

    magic_number = get_braves_magic_number()

    if magic_number == None or magic_number == "-":
        # Safe fallback if MLB is unavailable or the number is not active
        magic_number = "?"

    c.text_center(
        str(magic_number),
        11,
        font = "16x20",
        color = "white",
    )

    msg = ctx.inputs.get("setting1", "")

    if msg:
        c.text_center(
            str(msg).upper(),
            34,
            font = "5x7",
            color = "white",
        )
    c.image("atlanta-braves-logo.png", 9, 11)
