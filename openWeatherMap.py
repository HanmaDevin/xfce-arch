#!/usr/bin/python

# OpenWeatherMap service provides open weather data for more than 200,000
# cities and any geo location that is available on our website and through API.

import sys
import math
import requests

base_url = "http://api.openweathermap.org/data/2.5/weather"
api_key = "b918c40e31a1059bf4da78265f5aa440"  # << Get your API key (APPID) here: http://openweathermap.org/appid

icons = {
    "01d": " ",
    "01n": " ",
    "02d": " ",
    "02n": "",
    "09": " ",
    "10d": " ",
    "10n": " ",
    "10n 11n": " ",
    "10d 11d": " ",
    "11": "",
    "50": " ",
}


def get_icon(code):
    return icons[code]


def get_temperature(city):
    query = base_url + "?q=%s&units=metric&APPID=%s" % (city, api_key)
    try:
        response = requests.get(query)
        # print("[%s] %s" % (response.status_code, response.url))
        if response.status_code != 200:
            response = "N/A"
            return response
        else:
            weather_data = response.json()
            return weather_data
    except requests.exceptions.RequestException as error:
        print(error)
        sys.exit(1)


def main():
    location = get_temperature("Toenisvorst")
    code = location["weather"][0]["icon"]
    icon = get_icon(code)
    print(icon + " " + str(math.ceil(location["main"]["temp"])) + "°C")


if __name__ == "__main__":
    main()
