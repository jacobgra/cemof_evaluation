"""This is a proof of concept word counter of words from minutes of the Swedish central bank. Every governor's statements are extracted and counted for the words in the list 'words'. The code is not optimized and is only a proof of concept."""
import pdfplumber
import re
import os
import pprint


def extract_date(filename):
    # Regular expression to match dates like '16 mars 2020'
    pattern = r"([0-9]*)?-([a-z]*)-([0-9]*)(?=.pdf)"
    # Search for the date pattern in the filename
    match = re.search(pattern, filename)
    if match:
        return f"{match.group(1)} {match.group(2)} {match.group(3)}"
    return None

def extract_word_count(text,words):
    # Setup count dictionary
    governors =  {}
    comments_full = re.search(r'(?s)(Det ekonomiska läget och penningpolitiken)(.*?)§', text).group(2)
    comments_full = comments_full+" §"
    groups =  re.findall(r'(?s)((?<=Förste vice riksbankschef)|(?<=Vice riksbankschef)|(?<=Riksbankschef))(.*?)((?=Förste vice riksbankschef)|(?=Vice riksbankschef)|(?=Riksbankschef))|((?<=Förste vice riksbankschef)|(?<=Vice riksbankschef)|(?<=Riksbankschef)(.*?)§)', comments_full)
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
        """If multiple statements, add them together"""
        if name in governors:
            governors[name] = governors[name] + statement
        else:
            governors[name] = statement   
    for governor in governors:
        count = {}
        for elem in words:
            count[elem] = 0
        for i, el in enumerate(words):
            count[f'{words[i]}'] = governors[governor].count(el)
        governors[governor] = count
    return governors

def main():
    for entry in os.scandir("Data/minutes/"):
        extracted_date = extract_date(str(entry.path))
        pdf_file = entry.path
        if pdf_file == "Data/minutes/.DS_Store":
            continue
        print(pdf_file)
        words = ['inflation','ränta ','sysselsättning','pris ','växelkurs','skuld', 'belåning']
        # Get text from PDF source
        text = ''
        with pdfplumber.open(pdf_file) as pdf:
            for i, page in enumerate(pdf.pages):
                text = text+'\n'+str(page.extract_text())
        governors = extract_word_count(text,words)
        print(extracted_date+"\n")
        pprint.pprint(governors)
    return None
    
if __name__ == "__main__":
    main()