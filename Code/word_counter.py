"""This is a proof of concept word counter of words from minutes of the Swedish central bank. Every governor's statements are extracted and counted for the words in the list 'words'. The code is not optimized and is only a proof of concept."""
import pdfplumber
import re
import os
import pandas as pd
import timeit

# set directory
from os import chdir
chdir('/Users/edvinahlander/Library/CloudStorage/OneDrive-StockholmUniversity/PhD/Year 2/Courses/Monetary/Assignments/RB Evaluation/cemof_evaluation')

def extract_date(filename):
    pattern = r"([0-9]*)?-([a-z]*)-([0-9]*)(?=.pdf)"
    if filename.startswith('Data/older_minutes/pro_'):
        pattern = r"([0-9]{2})?([0-9]{2})([0-9]{2})"
    # Regular expression to match dates like '16 mars 2020'
    # Search for the date pattern in the filename
    match = re.search(pattern, filename)
    if match:
        return f"{match.group(1)} {match.group(2)} {match.group(3)}"
    return None


def convert_swedish_date(swedish_date):
    swedish_months = {
    "januari": "January", "februari": "February", "mars": "March", "april": "April",
    "maj": "May", "juni": "June", "juli": "July", "augusti": "August",
    "september": "September", "oktober": "October", "november": "November", "december": "December"
}
    for sv, en in swedish_months.items():
        if sv in swedish_date:
            swedish_date = swedish_date.replace(sv, en)
            break
    return pd.to_datetime(swedish_date, format='%d %B %Y')


def extract_word_count(text,words):
    # Setup count dictionary
    governors =  {}
    comments_full = re.search(r'(?s)(Det ekonomiska läget och penningpolitiken)(.*?)§', text).group(2)
    comments_full = comments_full+" §"
    groups =  re.findall(r'(?s)((?<=Förste vice riksbankschef )|(?<=Vice riksbankschef )|(?<=Riksbankschef ))(.*?)((?=Förste vice riksbankschef )|(?=Vice riksbankschef )|(?=Riksbankschef )|(?=§))', comments_full)
    for i in groups:
        """Handle problems with empty first string in groups of match"""
        j = 0
        try:
            while i[j] == '':
                j = j+1 
        except IndexError:
            continue
        statement = i[j]
        """Extract name of governor"""
        list = i[j].split()
        name = list[0]+" "+list[1]
        if (name == "Kerstin af")|(name == "Kerstin af:"):
            name = "Kerstin af Jochnick"
        if (name == "Lars E.O.")|(name == "Lars E.O.:"):
            name = "Lars E.O. Svensson"
        if name.endswith(':'):
            name = name[:-1]
        """If multiple statements, add them together"""
        if name in governors:
            governors[name] = governors[name] + statement
        else:
            governors[name] = statement.lower()
    for governor in governors:
        count = {}
        for elem in words:
            count[elem] = 0
        for i, el in enumerate(words):
            count[f'{words[i]}'] = governors[governor].count(el)
        count['Total'] = len(governors[governor].split())
        governors[governor] = count
    return governors

def main():
    data = []
    num_minutes = 0
    """Choose whether to analyse old or new minutes"""
    older = False
    if older == False:
        datadir = "Data/minutes/"
        storedir = "Data/governors_data.csv"
    else:
        datadir = "Data/older_minutes/"
        storedir = "Data/old_governors_data.csv"
    for entry in os.scandir(datadir):
        num_minutes += 1
        extracted_date = extract_date(str(entry.path))
        pdf_file = entry.path
        if pdf_file.endswith(".DS_Store"):
            continue
        hawk_words = ['inflation','kpif','lön','konsumentpris','producentpris','prissättning','energipris','oljepris','råvarupris','inflationsmål','kostnad','utbudsstörning','kron','växelkurs']
        dove_words = ['tillväxt','resursutnyttjande','sysselsättning','konjunktur','finansiella', 'bnp','skuldsättning','bolån','bostadsmarknad','räntekänslig','real','arbets']
        geo_words  = ['geopolitisk','handelskonflikt','handelshinder','tullar','protektionis','osäkerhet','krig','invasion']
        words = hawk_words + dove_words + geo_words
        # Get text from PDF source
        text = ''
        with pdfplumber.open(pdf_file) as pdf:
            for i, page in enumerate(pdf.pages):
                text = text+'\n'+str(page.extract_text())
        governors = extract_word_count(text,words)
        #print(extracted_date+"\n")
        if older == True:
            extracted_date = pd.to_datetime(extracted_date, format="%y %m %d")
        """Flattening the content of each governor"""
        for governor, counts in governors.items():
            row = {'date': extracted_date, 'governor': governor}
            row.update(counts)
            data.append(row)
    df = pd.DataFrame(data)
    if older == False:
        df['date'] = df['date'].apply(convert_swedish_date)
    else:
        pass
    df.to_csv(storedir, index=False)
    print(f"Minutes processed: {num_minutes}")
    return None
    
if __name__ == "__main__":
    main()
    