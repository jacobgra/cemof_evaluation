from word_counter import extract_word_count
import pdfplumber
import pprint

pdf_file = 'Data/minutes/protokoll-fran-det-penningpolitiska-motet-2-juli-2018.pdf'
hawk_words = ['inflation','kpif','lön','prissättning',  'energi', 'målet', 'olj', 'råvaru', 'livsmedel', 'utbudsstörning','utbud', 'kostnad', 'kron','växelkurs'] #'växelkurs','el'
dove_words = ['tillväxt','resursutnyttjande','sysselsättning','konjunktur', 'finansiella',  'bnp','skuldsättning','bolån','bostadsmarknad','räntekänslig', 'real', 'arbets','samhället' ] #'finans' 'skuld ,'belån'
geo_words = ['geopolitisk', 'handelskonflikt','handelshinder','tullar', 'protektionis','osäkerhet']
words = hawk_words + dove_words + geo_words
# Get text from PDF source
text = ''
with pdfplumber.open(pdf_file) as pdf:
    for i, page in enumerate(pdf.pages):
        text = text+'\n'+str(page.extract_text())
governors = extract_word_count(text,words)
pprint.pprint(governors)