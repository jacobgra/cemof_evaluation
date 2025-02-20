import requests
from bs4 import BeautifulSoup as bs
from urllib.request import urlopen


_base = 'https://www.riksbank.se/sv/press-och-publicerat/dagordningar-och-protokoll/penningpolitiska-protokoll/?year='
for year in range(2024,2025):
    _URL = _base + str(year)
    # functional
    r = requests.get(_URL)
    soup = bs(r.text,features="html.parser")
    urls = []
    names = []
    for i, link in enumerate(soup.findAll('a')):
        _FULLURL = _URL + link.get('href')
        if _FULLURL.endswith('.pdf'):
            urls.append(_FULLURL)
            names.append(soup.select('a')[i].attrs['href'])

    names_urls = zip(names, urls)

    for name, url in names_urls:
        response = requests.get(url)
        name = name.split('/')[-1]
        with open('./Data/minutes/'+name, 'wb') as f:
            f.write(response.content)