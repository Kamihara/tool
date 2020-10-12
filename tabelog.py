import shutil
import os
import filecmp

import requests
from bs4 import BeautifulSoup


YESTERDAY_FILE = 'yesterday.txt'
TODAY_FILE = 'today.txt'
# 赤坂焼肉 KINTAN コースメニューページ
URL = 'https://tabelog.com/tokyo/A1308/A130801/13177732/party/'

class Checker(object):
    def __init__(self, old_file, new_file):
        self.old_file = old_file
        self.new_file = new_file

    def get_diff(self):
        return filecmp.cmp(self.old_file, self.new_file)

class Client(object):
    def __init__(self, url):
        self.url = url

    def get_html(self):
        return requests.get(self.url).content


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
    print(checker.get_diff())