import requests
from bs4 import BeautifulSoup as bs
from urllib.request import urlopen


_base = 'https://www.riksbank.se/sv/press-och-publicerat/dagordningar-och-protokoll/penningpolitiska-protokoll/?year='
for year in range(2017,2026):
    _URL = _base + str(year)
    # functional
    r = requests.get(_URL)
    soup = bs(r.text,features="html.parser")
    urls = []
    names = []
    for i, link in enumerate(soup.findAll('a')):
        _FULLURL = link.get('href')
        if _FULLURL.endswith('.pdf'):
            urls.append("https://www.riksbank.se/"+_FULLURL)
            names.append(soup.select('a')[i].attrs['href'])

    names_urls = zip(names, urls)
    headers = {'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'}
    for name, url in names_urls:
        response = requests.get(url, stream = True, headers = headers)
        name = name.split('/')[-1]
        with open('./Data/minutes/'+name, 'wb') as f:
            f.write(response.content)
