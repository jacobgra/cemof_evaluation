"""
This file is used to fetch the pdf files from the Riksbank's website. The files are stored in subfolders of the Data folder. The subfolder in which the data is stored is determined by if the minutes are old or new. 
"""

import requests
from bs4 import BeautifulSoup as bs
import shutil

# set directory
from os import chdir
chdir('/Users/edvinahlander/Library/CloudStorage/OneDrive-StockholmUniversity/PhD/Year 2/Courses/Monetary/Assignments/RB Evaluation/cemof_evaluation')

""" Fetching new minutes """
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

"""Solving issue of 4 misnamed minutes"""
wrong_names = ['./Data/minutes/penningpolitiskt-protokoll-april-2021.pdf', 'Data/minutes/penningpolitiskt-protokoll-februari-2023.pdf', 'Data/minutes/penningpolitiskt-protokoll-juni-2024.pdf', 'Data/minutes/penningpolitiskt-protokoll-september-2020.pdf']
right_names = ['./Data/minutes/penningpolitiskt-protokoll-26-april-2021.pdf', './Data/minutes/penningpolitiskt-protokoll-8-februari-2023.pdf', './Data/minutes/penningpolitiskt-protokoll-26-juni-2024.pdf', './Data/minutes/penningpolitiskt-protokoll-21-september-2020.pdf']
for i, name in enumerate(wrong_names):
    shutil.move(name,right_names[i])

"""Moving new "incorrect" minutes """
excl_files = ['protokoll-fran-det-penningpolitiska-motet-12-mars-2020.pdf', 'protokoll-fran-det-penningpolitiska-motet-16-mars-2020.pdf', 'protokoll-fran-det-penningpolitiska-motet-19-mars-2020.pdf','protokoll-fran-det-penningpolitiska-motet-26-mars-2020.pdf','protokoll-fran-det-penningpolitiska-motet-den-21-april-2020-extrainsatt.pdf']
for file in excl_files:
    shutil.move('./Data/minutes/'+file,'./Data/excluded_minutes/'+file)

"""Fetching old minutes"""
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

"""Moving old "incorrect" minutes """
excl_files = ['rap_ppu_140904_sve.pdf', 'penningpolitiskt_121217_sve.pdf', 'pro_penningpol_120417.pdf','pro_penningpol_120703.pdf','pro_penningpol_120905_sve.pdf','pro_penningpol_121024_sve.pdf','pro_penningpolitiskt_160104_sve.pdf','pro_penningpolitiskt_160119_sve.pdf','probil_dir_A_160104_sve.pdf' , 'probil_dir_B_160104_sve.pdf','rap_ppr_140703_sve.pdf','rap_ppr_141028_sve.pdf','rap_ppr_150212_sve.pdf' , 'rap_ppr_150429_sve_reviderad.pdf','rap_ppu_140409_sve.pdf']
for file in excl_files:
    shutil.move('./Data/older_minutes/'+file,'./Data/excluded_minutes/gamla_exkluderade/'+file)