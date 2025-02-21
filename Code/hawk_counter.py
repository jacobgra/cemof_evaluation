import pdfplumber
pdf_file = "Data/minutes/penningpolitiskt-protokoll-26-mars-2024.pdf"
words = ['inflation','ränta ','sysselsättning','pris ','växelkurs','skuld', 'belåning']

# Get text
text = ''
with pdfplumber.open(pdf_file) as pdf:
    for i, page in enumerate(pdf.pages):
        text = text+'\n'+str(page.extract_text())

# Setup count dictionary
governors =  {}

print(governors)
count = {}
for elem in words:
    count[elem] = 0
        
# Count occurences
for i, el in enumerate(words):
    count[f'{words[i]}'] = text.count(el)

print(count)