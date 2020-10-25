import filecmp

import requests
from bs4 import BeautifulSoup

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



