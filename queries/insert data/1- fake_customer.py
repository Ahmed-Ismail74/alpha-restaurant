import csv
import random
from faker import Faker
from datetime import date

# Initialize Faker
fake = Faker()
Faker.seed(0)
random.seed(0)

def generate_egyptian_phone_number():
    area_code = "01"  # Egyptian mobile phone numbers typically start with "01"
    operator_code = random.choice(["0", "1", "2", "5", "6", "9"])  # Random operator code
    subscriber_number = ''.join(random.choices('0123456789', k=8))  # 8 random digits for subscriber number
    return f"{area_code}{operator_code}{subscriber_number}"

# Generate 200 Egyptian phone numbers
egyptian_phone_numbers = [generate_egyptian_phone_number() for _ in range(1000)]

print(egyptian_phone_numbers)

# Expanded list of common Egyptian first names and last names
egyptian_first_names_male = [
    'Ahmed', 'Mohamed', 'Mahmoud', 'Mustafa', 'Youssef', 'Omar', 'Abdullah', 'Hassan', 'Ibrahim', 'Ali',
    'Khaled', 'Tamer', 'Amr', 'Rami', 'Samir', 'Ehab', 'Nasser', 'Said', 'Fouad', 'Karim',
    'Adham', 'Hisham', 'Sherif', 'Hazem', 'Wael', 'Yassin', 'Maged', 'Tarek', 'Hosni', 'Nader',
    'Hadi', 'Ziad', 'Fadi', 'Ayman', 'Kareem', 'Walid', 'Taha', 'Sameh', 'Yahya', 'Hatem',
    'Raafat', 'Maher', 'Majed', 'Emad', 'Mohsen', 'Sami', 'Bassem', 'Fares', 'Majid', 'Ossama',
    'Ashraf', 'Mohab', 'Ismail', 'Adel', 'Mahdi', 'Amer', 'Kamal', 'Moez', 'Rashad', 'Hamza',
    'Hani', 'Nabil', 'Khalid', 'Hossam', 'Salah', 'Mamdouh', 'Tawfiq', 'Medhat'
]


egyptian_first_names_female = [
    'Fatma', 'Sara', 'Mona', 'Aya', 'Nour', 'Hala', 'Nadia', 'Marwa', 'Dina', 'Heba',
    'Layla', 'Yasmin', 'Aisha', 'Salma', 'Rania', 'Lina', 'Shimaa', 'Eman', 'Farida', 'Karima', 
    'Maysa', 'Maya', 'Zahra', 'Yara', 'Huda', 'Safia', 'Amina', 'Dalal', 'Inas', 'Nada', 
    'Shadia', 'Samar', 'Naglaa', 'Rasha', 'Ghada', 'Rawya', 'Reem', 'Shaimaa', 'Zeinab', 'Wafaa', 
    'Sahar', 'Faten', 'Sabah', 'Hayat', 'Asma', 'Nahla', 'Nihal', 'Hanan', 'Gihan', 'Mervat',
    'Dalia', 'Soaad', 'Rabab', 'Manal', 'Soad', 'Noha', 'Amal', 'Ragaa', 'Abeer', 'Hoda', 
    'Shaza', 'Nermeen', 'Asmaa', 'Warda', 'Siham', 'Maha', 'Shereen', 'Riham', 'Laila', 'Habiba',
    'Fatima', 'Shereef', 'Nermin', 'Fathiya', 'Ola', 'Zainab', 'Safiya'
]

egyptian_last_names = [
    'Amr', 'Tarek', 'Hisham', 'Sherif', 'Hossam', 'Ahmad', 'Ossama', 'Kamal', 'Hatem', 'Yahya',
    'Mina', 'Ashraf', 'Sami', 'Maged', 'Hani', 'Mahmoud', 'Emad', 'Mohsen', 'Mohab', 'Yasser',
    'Hamdy', 'Adel', 'Rami', 'Mamdouh', 'Wael', 'Youssef', 'Fouad', 'Hassan', 'Mohammed', 'Yousef',
    'Mahmoud', 'Karim', 'Mohsen', 'Hassan', 'Tamer', 'Mahmoud', 'Ismail', 'Hussein', 'Moustafa', 'Mamdouh',
    'Ahmed', 'Mohsen', 'Ali', 'Rami', 'Mohammed', 'Hisham', 'Ibrahim', 'Khaled', 'Adham', 'Mohamed'
]

# Dictionary containing the addresses
egyptian_addresses_dict = {
    1: {'Street': '32 El-Falaky St., Bab El-Louk', 'City': 'Cairo'},
    2: {'Street': '49 El-Shaheed Moustafa Hafez St., Mansheya', 'City': 'Alexandria'},
    3: {'Street': '32 Elbatal Ahmed Abdelaziz, P.O. Box: 202', 'City': 'Cairo'},
    4: {'Street': '35 El Hegaz St., AIN SHAMS', 'City': 'Cairo'},
    5: {'Street': '14 Talaat Harb St., DOWNTOWN', 'City': 'Cairo'},
    6: {'Street': '3rd District, Public Free Zone', 'City': 'Port Said'},
    7: {'Street': '63 Amoud El Sawari St., KARMOUZ', 'City': 'Alexandria'},
    8: {'Street': '19 Islam St., HAMAMAT EL KOBBA', 'City': 'Cairo'},
    9: {'Street': '385 El Horreya Rd., MOSTAFA KAMEL', 'City': 'Alexandria'},
    10: {'Street': '3 Bilouz St., EL IBRAHIMEYA', 'City': 'Alexandria'},
    11: {'Street': '35 Abou El Dardaa St., AL LABAN', 'City': 'Alexandria'},
    12: {'Street': '5 Dawlatian El-Khalafawy St., SHOUBRA', 'City': 'Cairo'},
    13: {'Street': '98 Tahrir St., Dokki', 'City': 'Giza'},
    14: {'Street': 'Ind. Zone, Malash St.', 'City': 'Gharbeya'},
    15: {'Street': '23 Wadi El Nile St., MOHANDESEEN', 'City': 'Giza'},
    16: {'Street': '6 El-Selsoul St., Garden City', 'City': 'Cairo'},
    17: {'Street': '12 B El Marwa Bldgs., Nabil El Wakkad St.', 'City': 'Heliopolis'},
    18: {'Street': '19 Mohamed Ramzy St., Safir Sq.', 'City': 'Heliopolis'},
    19: {'Street': '15 Megawra No.5, 2nd district, New Damietta', 'City': 'Damietta'},
    20: {'Street': '10th Of Ramadan St., Off 30 St.', 'City': 'Alexandria'},
    21: {'Street': '29 Mostafa Kamel Sq., SEMOUHA', 'City': 'Alexandria'},
    22: {'Street': '1353 Corniche El-Nile, El-Khalafawi', 'City': 'Cairo'},
    23: {'Street': '10 Nasr El Din Bahgat St., 8th District', 'City': 'Cairo'},
    24: {'Street': '3 Abou El-Feda St., ZAMALEK', 'City': 'Cairo'},
    25: {'Street': '14 Koleiet El Banat Project Behind Air Defence House - El Nozha St., HELIOPOLIS', 'City': 'Cairo'},
    26: {'Street': 'El Rasafa Sq., MOHARRAM BEY', 'City': 'Alexandria'},
    27: {'Street': '162 Tahrir St. Babelouq, Cairo.', 'City': 'Cairo'},
    28: {'Street': '7 Street Ibrahim El Side Sidi Basher, Alexandria', 'City': 'Alexandria'},
    29: {'Street': '12 Hussein Kamel Kamel Selim St., Almaza', 'City': 'Heliopolis'},
    30: {'Street': '18 Hassan Assem St., Off Hassan Sabry St.', 'City': 'Zamalek'},
    31: {'Street': '19 Abbas El-Akkad St., NASR CITY', 'City': 'Cairo'},
    32: {'Street': 'Industrial Zone, Block 1 New Damietta', 'City': 'Damietta'},
    33: {'Street': '15 Ibn Batota St., Madkour', 'City': 'El Haram'},
    34: {'Street': '9 El-Kamel Mohamed St., Flat 22', 'City': 'Zamalek'},
    35: {'Street': '70 El Merghany St., Koleyat El Bannat', 'City': 'Heliopolis'},
    36: {'Street': '17 El Shahid Sherif Ramzy St., SEMOUHA', 'City': 'Alexandria'},
    37: {'Street': '11th Fareed Sebae St., Haram, Giza.', 'City': 'Haram'},
    38: {'Street': '18 Nawal St., DOKKI', 'City': 'Cairo'},
    39: {'Street': '11 Iran St., DOKKI', 'City': 'Cairo'},
    40: {'Street': '130, Gesr El Suez St', 'City': 'Cairo'},
    41: {'Street': '4 Al Yousr St., MOHANDESEEN', 'City': 'Cairo'},
    42: {'Street': '43 Abd El-Hamid Abu Hef St., HELIOPOLIS', 'City': 'Cairo'},
    43: {'Street': '46 Faisal St., FAISAL', 'City': 'Cairo'},
    44: {'Street': 'Manial Sheha, GIZA', 'City': 'Giza'},
    45: {'Street': '25 Hussien Abou Elfadel St., Alharam', 'City': 'Giza'},
    46: {'Street': '5 Mahmoud Sedky St., El Mahrous Tower P. O Box 197', 'City': 'Port Said'},
    47: {'Street': '268 Ext. Ramsis 2 St., in front off Conference Center', 'City': 'Nasr City'},
    48: {'Street': '119 Ramsis St., 3rd Floor; in front of ElHelal ElAhmar', 'City': 'Downtown'},
    49: {'Street': '68 St. No. 4, El-Nafoura Sq., El-Mokkatam', 'City': 'El-qalaa'},
    50: {'Street': '93, Taawoneyat Semouha', 'City': 'Semouha'},
    51: {'Street': '268 Ext. Ramsis 2 St., in front off Conference Center', 'City': 'Nasr City'},
    52: {'Street': '6 El Bashir St., El Khalafawy Sq.', 'City': 'Shoubra'},
    53: {'Street': 'El-Tabia, Khat Rashid', 'City': 'Alexandria'},
    54: {'Street': '12 Hassan Aflaton St., Ayoub Project, Ard El-Golf', 'City': 'Heliopolis'},
    55: {'Street': '31 Loosaka St., off Ahmed Fakhry St.', 'City': 'Nasr City'},
    56: {'Street': '16 Eldwedar St., HADAYEK EL KOBBA', 'City': 'Cairo'},
    57: {'Street': '4 Ammar Ibn Yasser St., behind Millatery Acadamy', 'City': 'Heliopolis'},
    58: {'Street': '69 Safar Bey St., RAS EL TIN', 'City': 'Alexandria'},
    59: {'Street': '159 El-Moez Ledin Allah El-Fatami, Bab El-Shaareya', 'City': 'Downtown'},
    60: {'Street': '10 Dr. Mohamed Awad St., Nasr City, Cairo', 'City': 'Cairo'},
    61: {'Street': '10 El Sayed El Bblawy St., Ard Sherif Abdin', 'City': 'Cairo'},
    62: {'Street': '7 El Nasr St. El Nozha El Gededa St., HELIOPOLIS', 'City': 'Cairo'},
    63: {'Street': '309 Tarik El Horreya, P.O. Box: 203', 'City': 'Alexandria'},
    64: {'Street': '92 Tahrir St., DOKKI', 'City': 'Cairo'},
    65: {'Street': '3 Sabry Abu Alam St., Bab El-Louk', 'City': 'Abdin'},
    66: {'Street': '18 Helal St., Off Ezz El Din Omar St.', 'City': 'El Haram'},
    67: {'Street': '33 St. No.14, Maadi', 'City': 'Cairo'},
    68: {'Street': '100-El Moaz Ledin Elah EL Famtamy, EL Gamlia St., Cairo', 'City': 'Cairo'},
    69: {'Street': '37 Shehab St., Mohandessin', 'City': 'Giza'},
    70: {'Street': 'El-Ghoury and Kisra St., PORT SAID', 'City': 'Port Said'},
    71: {'Street': '21 Kamel Sedky, Fagala', 'City': 'Cairo'},
    72: {'Street': '289 Faisal St., FAISAL', 'City': 'Giza'},
    73: {'Street': '3 El Obour Bldgs., Salah Salem', 'City': 'Nasr City'},
    74: {'Street': '15 Ali El-Kassar St., off Emad El-Din St.', 'City': 'Downtown'},
    75: {'Street': 'Housing Bank Bldg. 49, El-Dawahi', 'City': 'Port Said'},
    76: {'Street': '3 Saad Sadek El Deweny St., Triumph Sq.', 'City': 'Heliopolis'},
    77: {'Street': '8 A Omar Ibn El Khatab St., MOHANDESEEN', 'City': 'Cairo'},
    78: {'Street': '32 El-Falaky St., Bab El-Louk', 'City': 'Cairo'}, # Repeated with same address
    79: {'Street': '50 El-Shaheed Moustafa Hafez St., Mansheya', 'City': 'Alexandria'}, # Repeated with changed number
    80: {'Street': '33 Elbatal Ahmed Abdelaziz, P.O. Box: 202', 'City': 'Cairo'}, # Repeated with changed number
    81: {'Street': '36 El Hegaz St., AIN SHAMS', 'City': 'Cairo'}, # Repeated with changed number
    82: {'Street': '15 Talaat Harb St., DOWNTOWN', 'City': 'Cairo'}, # Repeated with changed number
    83: {'Street': '3rd District, Public Free Zone', 'City': 'Port Said'}, # Repeated with same address
    84: {'Street': '64 Amoud El Sawari St., KARMOUZ', 'City': 'Alexandria'}, # Repeated with changed number
    85: {'Street': '20 Islam St., HAMAMAT EL KOBBA', 'City': 'Cairo'}, # Repeated with changed number
    86: {'Street': '386 El Horreya Rd., MOSTAFA KAMEL', 'City': 'Alexandria'}, # Repeated with changed number
    87: {'Street': '4 Bilouz St., EL IBRAHIMEYA', 'City': 'Alexandria'}, # Repeated with changed number
    88: {'Street': '36 Abou El Dardaa St., AL LABAN', 'City': 'Alexandria'}, # Repeated with changed number
    89: {'Street': '6 Dawlatian El-Khalafawy St., SHOUBRA', 'City': 'Cairo'}, # Repeated with changed number
    90: {'Street': '99 Tahrir St., Dokki', 'City': 'Giza'}, # Repeated with changed number
    91: {'Street': 'Ind. Zone, Malash St.', 'City': 'Gharbeya'}, # Repeated with same address
    92: {'Street': '24 Wadi El Nile St., MOHANDESEEN', 'City': 'Giza'}, # Repeated with changed number
    93: {'Street': '7 El-Selsoul St., Garden City', 'City': 'Cairo'}, # Repeated with changed number
    94: {'Street': '13 B El Marwa Bldgs., Nabil El Wakkad St.', 'City': 'Heliopolis'}, # Repeated with changed number
    95: {'Street': '20 Mohamed Ramzy St., Safir Sq.', 'City': 'Heliopolis'}, # Repeated with changed number
    96: {'Street': '16 Megawra No.5, 2nd district, New Damietta', 'City': 'Damietta'}, # Repeated with changed number
    97: {'Street': '11th Of Ramadan St., Off 30 St.', 'City': 'Alexandria'}, # Repeated with changed number
    98: {'Street': '30 Mostafa Kamel Sq., SEMOUHA', 'City': 'Alexandria'}, # Repeated with changed number
    99: {'Street': '1354 Corniche El-Nile, El-Khalafawi', 'City': 'Cairo'}, # Repeated with changed number
    100: {'Street': '11 Nasr El Din Bahgat St., 8th District', 'City': 'Cairo'}, # Repeated with changed number
    101: {'Street': '25 Souk Shedia St., EL IBRAHIMEYA', 'City': 'Alexandria'},
    102: {'Street': '22 Zaker Hussein St. Nasr City, P.O. Box: 11371', 'City': 'Cairo'},
    103: {'Street': 'Opp. 17 Ibrahim El Halabi St., GLIM', 'City': 'Alexandria'},
    104: {'Street': '30 A Serganey St, Abdu Pasha Sq Abbassia 11381', 'City': 'Cairo'},
    105: {'Street': 'Dobat Bldgs. 25 El-Akhaa City, Corniche El-Nil, Torah', 'City': 'Cairo'},
    106: {'Street': '5 Amer St., Messhaha Sq.', 'City': 'Giza'},
    107: {'Street': '92 Shehab St., MOHANDESEEN', 'City': 'Giza'},
    108: {'Street': '32 El-Thawra St., MOHANDESEEN', 'City': 'Giza'},
    109: {'Street': '14 Zaki Elmohandess Elnozha Elgedda', 'City': 'Cairo'},
    110: {'Street': '5 Tahrir Sq., Down Town', 'City': 'Cairo'},
    111: {'Street': '9 Ayoub St., Beside El Haram Civil Registration', 'City': 'Cairo'},
    112: {'Street': 'El-Baladeya and El-Kaliubeya St., El-Arab', 'City': 'Port Said'},
    113: {'Street': 'Mecca St., EL ASAFRA KEBLY', 'City': 'Alexandria'},
    114: {'Street': '82 Sudan St., MOHANDESEEN', 'City': 'Giza'},
    115: {'Street': 'Ard ElGolf Bldg. 73 Saad Zghloul St., Dawahie District', 'City': 'Port Said'},
    116: {'Street': '29 Rabaa Inv.Project, Nozha St.', 'City': 'Cairo'},
    117: {'Street': 'Housing Bank Bldg. No. 6, El-Dawahi', 'City': 'Port Said'},
    118: {'Street': 'Behind El Marikh Club, PORT SAID', 'City': 'Port Said'},
    119: {'Street': 'Feryaal Tower Bldg. Mohamed Mahmoud and El-Guish St., El-Sharq', 'City': 'Port Said'},
    120: {'Street': 'El-Forat & El-Gomhoureya St., El-Sharq', 'City': 'Port Said'},
    121: {'Street': '355 El-Horreya Rd., Sidi Gaber', 'City': 'Alexandria'},
    122: {'Street': '32 El Obour Bldgs., Salah Salem Nasr City', 'City': 'Cairo'},
    123: {'Street': '112, 26 Of July Str, Zamalek', 'City': 'Cairo'},
    124: {'Street': '26 Zaker Hussein St. Nasr City, P.O. Box: 11371', 'City': 'Cairo'}, # Repeated with changed number
    125: {'Street': '36 Souk Shedia St., EL IBRAHIMEYA', 'City': 'Alexandria'}, # Repeated with changed number
    126: {'Street': '35 A Serganey St, Abdu Pasha Sq Abbassia 11381', 'City': 'Cairo'}, # Repeated with changed number
    127: {'Street': 'Dobat Bldgs. 28 El-Akhaa City, Corniche El-Nil, Torah', 'City': 'Cairo'}, # Repeated with changed number
    128: {'Street': '10 Amer St., Messhaha Sq.', 'City': 'Giza'}, # Repeated with changed number
    129: {'Street': '95 Shehab St., MOHANDESEEN', 'City': 'Giza'}, # Repeated with changed number
    130: {'Street': '35 El-Thawra St., MOHANDESEEN', 'City': 'Giza'}, # Repeated with changed number
    131: {'Street': '20 Zaki Elmohandess Elnozha Elgedda', 'City': 'Cairo'}, # Repeated with changed number
    132: {'Street': '10 Tahrir Sq., Down Town', 'City': 'Cairo'}, # Repeated with changed number
    133: {'Street': '15 Ayoub St., Beside El Haram Civil Registration', 'City': 'Cairo'}, # Repeated with changed number
    134: {'Street': 'El-Baladeya and El-Kaliubeya St., El-Arab', 'City': 'Port Said'}, # Repeated with same address
    135: {'Street': '18 Mecca St., EL ASAFRA KEBLY', 'City': 'Alexandria'}, # Repeated with changed number
    136: {'Street': '88 Sudan St., MOHANDESEEN', 'City': 'Giza'}, # Repeated with changed number
    137: {'Street': 'Ard ElGolf Bldg. 76 Saad Zghloul St., Dawahie District', 'City': 'Port Said'}, # Repeated with changed number
    138: {'Street': '35 Rabaa Inv.Project, Nozha St.', 'City': 'Cairo'}, # Repeated with changed number
    139: {'Street': 'Housing Bank Bldg. No. 9, El-Dawahi', 'City': 'Port Said'}, # Repeated with changed number
    140: {'Street': 'Behind El Marikh Club, PORT SAID', 'City': 'Port Said'}, # Repeated with same address
    141: {'Street': 'Feryaal Tower Bldg. 36 Mohamed Mahmoud and El-Guish St., El-Sharq', 'City': 'Port Said'}, # Repeated with changed number
    142: {'Street': 'El-Forat & El-Gomhoureya St., El-Sharq', 'City': 'Port Said'}, # Repeated with same address
    143: {'Street': '360 El-Horreya Rd., Sidi Gaber', 'City': 'Alexandria'}, # Repeated with changed number
    144: {'Street': '38 El Obour Bldgs., Salah Salem Nasr City', 'City': 'Cairo'}, # Repeated with changed number
    145: {'Street': '118, 26 Of July Str, Zamalek', 'City': 'Cairo'}, # Repeated with changed number
    146: {'Street': '27 Souk Shedia St., EL IBRAHIMEYA', 'City': 'Alexandria'},
    147: {'Street': '23 Zaker Hussein St., Nasr City, P.O. Box: 11371', 'City': 'Cairo'},
    148: {'Street': 'Opp. 18 Ibrahim El Halabi St., GLIM', 'City': 'Alexandria'},
    149: {'Street': '31 A Serganey St., Abdu Pasha Sq Abbassia 11381', 'City': 'Cairo'},
    150: {'Street': 'Dobat Bldgs. 26 El-Akhaa City, Corniche El-Nil, Torah', 'City': 'Cairo'},
    151: {'Street': '6 Amer St., Messhaha Sq.', 'City': 'Giza'},
    152: {'Street': '93 Shehab St., MOHANDESEEN', 'City': 'Giza'},
    153: {'Street': '33 El-Thawra St., MOHANDESEEN', 'City': 'Giza'},
    154: {'Street': '15 Zaki Elmohandess Elnozha Elgedda', 'City': 'Cairo'},
    155: {'Street': '6 Tahrir Sq., Down Town', 'City': 'Cairo'},
    156: {'Street': '10 Ayoub St., Beside El Haram Civil Registration', 'City': 'Cairo'},
    157: {'Street': 'El-Baladeya and El-Kaliubeya St., El-Arab', 'City': 'Port Said'}, # Repeated with same address
    158: {'Street': '17 Mecca St., EL ASAFRA KEBLY', 'City': 'Alexandria'},
    159: {'Street': '85 Sudan St., MOHANDESEEN', 'City': 'Giza'},
    160: {'Street': 'Ard ElGolf Bldg. 74 Saad Zghloul St., Dawahie District', 'City': 'Port Said'},
    161: {'Street': '32 Rabaa Inv.Project, Nozha St.', 'City': 'Cairo'},
    162: {'Street': 'Housing Bank Bldg. No. 7, El-Dawahi', 'City': 'Port Said'},
    163: {'Street': 'Behind El Marikh Club, PORT SAID', 'City': 'Port Said'}, # Repeated with same address
    164: {'Street': 'Feryaal Tower Bldg. 35 Mohamed Mahmoud and El-Guish St., El-Sharq', 'City': 'Port Said'},
    165: {'Street': 'El-Forat & El-Gomhoureya St., El-Sharq', 'City': 'Port Said'}, # Repeated with same address
    166: {'Street': '357 El-Horreya Rd., Sidi Gaber', 'City': 'Alexandria'},
    167: {'Street': '35 El Obour Bldgs., Salah Salem Nasr City', 'City': 'Cairo'},
    168: {'Street': '113, 26 Of July Str, Zamalek', 'City': 'Cairo'},
    169: {'Street': '34 Souk Shedia St., EL IBRAHIMEYA', 'City': 'Alexandria'},
    170: {'Street': '28 Zaker Hussein St., Nasr City, P.O. Box: 11371', 'City': 'Cairo'},
    171: {'Street': 'Opp. 19 Ibrahim El Halabi St., GLIM', 'City': 'Alexandria'},
    172: {'Street': '32 A Serganey St., Abdu Pasha Sq Abbassia 11381', 'City': 'Cairo'},
    173: {'Street': 'Dobat Bldgs. 29 El-Akhaa City, Corniche El-Nil, Torah', 'City': 'Cairo'},
    174: {'Street': '9 Amer St., Messhaha Sq.', 'City': 'Giza'},
    175: {'Street': '96 Shehab St., MOHANDESEEN', 'City': 'Giza'},
    176: {'Street': '36 El-Thawra St., MOHANDESEEN', 'City': 'Giza'},
    177: {'Street': '18 Zaki Elmohandess Elnozha Elgedda', 'City': 'Cairo'},
    178: {'Street': '11 Tahrir Sq., Down Town', 'City': 'Cairo'},
    179: {'Street': '16 Ayoub St., Beside El Haram Civil Registration', 'City': 'Cairo'},
    180: {'Street': 'El-Baladeya and El-Kaliubeya St., El-Arab', 'City': 'Port Said'}, # Repeated with same address
    181: {'Street': '20 Mecca St., EL ASAFRA KEBLY', 'City': 'Alexandria'},
    182: {'Street': '89 Sudan St., MOHANDESEEN', 'City': 'Giza'},
    183: {'Street': 'Ard ElGolf Bldg. 77 Saad Zghloul St., Dawahie District', 'City': 'Port Said'},
    184: {'Street': '38 Rabaa Inv.Project, Nozha St.', 'City': 'Cairo'},
    185: {'Street': 'Housing Bank Bldg. No. 10, El-Dawahi', 'City': 'Port Said'},
    186: {'Street': 'Behind El Marikh Club, PORT SAID', 'City': 'Port Said'}, # Repeated with same address
    187: {'Street': 'Feryaal Tower Bldg. 37 Mohamed Mahmoud and El-Guish St., El-Sharq', 'City': 'Port Said'},
    188: {'Street': 'El-Forat & El-Gomhoureya St., El-Sharq', 'City': 'Port Said'}, # Repeated with same address
    189: {'Street': '361 El-Horreya Rd., Sidi Gaber', 'City': 'Alexandria'},
    190: {'Street': '39 El Obour Bldgs., Salah Salem Nasr City', 'City': 'Cairo'},
    191: {'Street': '119, 26 Of July Str, Zamalek', 'City': 'Cairo'}
}
# Define the file path
file_path = 'egyptian_customers_basic.csv'

# Define the header for the new procedure
header_basic = [
    'fn_cust_first_name', 
    'fn_cust_last_name', 
    'fn_cust_gender', 
    'fn_cust_phone', 
    'fn_cust_address', 
    'fn_cust_city', 
    'fn_location_coordinates', 
    'fn_cust_birthdate'
]

# Open the file in write mode
with open(file_path, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(header_basic)
    
    # Generate and write 5000 customers with Egyptian names and diverse cities
    for _ in range(300):
        gender = random.choice(['m', 'f'])
        if gender == 'm':
            first_name = random.choice(egyptian_first_names_male)
        else:
            first_name = random.choice(egyptian_first_names_female)
        last_name = random.choice(egyptian_last_names)
        phone = random.choice(egyptian_phone_numbers)
        address_data = random.choice(list(egyptian_addresses_dict.values()))  # Randomly select an address data from the dictionary
        address = address_data['Street']
        city = address_data['City']
        birthdate = fake.date_of_birth(minimum_age=18, maximum_age=80)
        location_coordinates = None  # Optional field
        
        writer.writerow([
            first_name, 
            last_name, 
            gender, 
            phone, 
            address, 
            city, 
            location_coordinates, 
            birthdate
        ])

print(f"Data generation complete. File saved as {file_path}")