import shutil
import os

from bs4 import BeautifulSoup

from tabelog import Client
from tabelog import Checker

from line import send_to_line


YESTERDAY_FILE = 'yesterday.txt'
TODAY_FILE = 'today.txt'
# 赤坂焼肉 KINTAN コースメニューページ
URL = 'https://tabelog.com/tokyo/A1308/A130801/13177732/party/'
CHANNEL_ACCESS_TOKEN = 'jV91aUy1HupqZT6Uy6fYEmT/6Q1hPZuzIEVVrL/TweqwbIYqPDxJ90vXer59rGs/HU7p3jaXxBT34nomyIf5AxZDYuwvu1a3En+g5DS0Un9zZKqPmWBLNi8m+ydB28WQgPjMAXvlVdZZr3X4jDohJgdB04t89/1O/w1cDnyilFU='
TO_ID = 'Ueef2a5eb2fdc3cd18d88b9b14ecd4da1'
MSG = 'Hello, world!'


if __name__ == "__main__":
    if os.path.exists(TODAY_FILE):
        shutil.copy(TODAY_FILE, YESTERDAY_FILE)
        os.remove(TODAY_FILE)

    client = Client(URL)
    html = client.get_html()
    soup = BeautifulSoup(html, 'html.parser')
    cource_list = soup.find(class_='course-list__items')

    with open(TODAY_FILE, 'w') as f:
        f.write(str(cource_list))

    checker = Checker(TODAY_FILE, YESTERDAY_FILE)
    if checker.get_diff():
        send_to_line(CHANNEL_ACCESS_TOKEN, TO_ID, MSG)