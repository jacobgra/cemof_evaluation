import requests
from bs4 import BeautifulSoup as bs

""" För hämtning av nya protokoll """
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


"""För hämtning av gamla protokoll"""
_base = 'https://archive.riksbank.se/sv/Webbarkiv/Publicerat/Penningpolitiska-protokoll/'
for year in range(2012,2017):
    if year == 2013:
        year = 20131
    if year == 2015:
        year = 20151
    
    _URL = _base + str(year)
   
    # functional
    r = requests.get(_URL)
    soup = bs(r.text,features="html.parser")
    urls = []
    names = []
    for i, link in enumerate(soup.findAll('a')):
        _FULLURL = link.get('href')
        if _FULLURL.startswith('Protokoll'):
            r = requests.get(_URL+"/"+_FULLURL)
            soup1 = bs(r.text,features="html.parser")
            for i, link in enumerate(soup1.findAll('a')):
                _SUBURL = link.get('href')
                if _SUBURL == None:
                    continue
                if _SUBURL.endswith('.pdf'):
                    urls.append("https://archive.riksbank.se/"+_SUBURL[18:])
                    names.append(_SUBURL[18:])
    names_urls = zip(names, urls)
    headers = {'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'}
    for name, url in names_urls:
        print(url)
        response = requests.get(url, stream = True, headers = headers)
        name = name.split('/')[-1]
        print(name)
        with open('./Data/older_minutes/'+name, 'wb') as f:
            f.write(response.content)