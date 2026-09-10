# Flight Fare Tracker

Shows the current fare for one flight on one day, pulled from Google Flights
through [SerpApi](https://serpapi.com), with a LOW / TYPICAL / HIGH verdict for
the route from Google's own price insights.

## Getting a SerpApi key

1. Create a free account at https://serpapi.com/users/sign_up.
2. Open https://serpapi.com/manage-api-key and copy the **Private API key**.
3. Paste it into the **SerpApi API key** setting. It is stored encrypted and
   you only enter it once; changing the flight does not need it again.

The free plan includes **250 searches a month**. This app runs one search per
refresh, every two hours, which is about 12 a day: a free key covers roughly
three weeks of continuous tracking, and the app stops searching once the
flight has departed. Paid plans start at 1,000 searches a month.

## Settings

| Setting | Example | Notes |
|---|---|---|
| Flight number | `B6 1234` | Airline code plus number. Spaces and dashes are fine. |
| Origin airport | `MCO` | Three-letter IATA code. |
| Destination airport | `JFK` | Three-letter IATA code. |
| Departure date | | The day the flight leaves. |
| Travelers | `1` | Adults on the booking. The fare is quoted for this many. |
| Cabin | `ECONOMY` | Economy, premium economy, business or first. |

Leave the key blank to see a labelled demo fare and check the layout first.

## What the panel shows

- The airline and flight number in the carrier's color, and the route.
- The fare, green when Google rates it LOW for the route, red when HIGH.
- If Google does not list that exact flight number on that day, the lowest
  fare on the route is shown instead and the chip row says `LOWEST ON ROUTE`.
- A two-line card for anything else: a missing setting, a rejected key, the
  monthly limit, or SerpApi being unreachable.
