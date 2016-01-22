# IBM_Watson_NLC_ICD10_Health_Codes
ICD-10 nternational Statistical Classification of Diseases and Related Health Problems  - Ground Truth and some Experimental R Code for NL Classifier

BLOG --- https://dreamtolearn.com/ryan/r_journey_to_watson/17
SERVICE - http://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/nl-classifier.html  

Background

ICD-10 is the International Statistical Classification of Diseases and Related Health Problems 10th Revision.  It's a REALLY long list of codes that hospitals and insurance companies use to classify treatments.

It's 65k+ rows of ailments.  It's a big and interesting data set.

At a recent IBM Watson team summit, the data set came up in a conversation with a colleague.  I was curious if we could create a QUICK AND DIRTY natural language classifier that would take a speech or text input, and output the top 10 most likely matches.

Benefits of such a system would include:

    -More accurate tagging of PRIMARY and SECONDARY ICD 10 Codes - better data for all the reasons that the codes exist in the first place (better fit)
    
    -More profitability for hospitals (assuming better tagging can translate to more successful claims from insurance companies)
    
    -Save Time - less rework and re-classification

    WIKI:  https://en.wikipedia.org/wiki/ICD-10#List

 
SOURCE CODE

CAVEAT:  THIS GROUND TRUTH WAS PREPARED IN 30 MINUTES - IT IS NOT A SOLUTION, BUT RATHER AN EXAMPLE OF ONE PART OF A WIDER APPROACH.
https://github.com/rustyoldrake/IBM_Watson_NLC_ICD10_Health_Codes
BLOG: https://dreamtolearn.com/ryan/r_journey_to_watson/16

 
 
ICD-10 Organization ======

Here's what it looks like at a meta level:

Chapter    Blocks    Title
I    A00–B99 Certain infectious and parasitic diseases
II    C00–D48 Neoplasms
III    D50–D89 Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism
IV    E00–E90 Endocrine, nutritional and metabolic diseases
V    F00–F99 Mental and behavioural disorders
VI    G00–G99 Diseases of the nervous system
VII    H00–H59 Diseases of the eye and adnexa
VIII    H60–H95 Diseases of the ear and mastoid process
IX    I00–I99 Diseases of the circulatory system
X    J00–J99 Diseases of the respiratory system
XI    K00–K93 Diseases of the digestive system
XII    L00–L99 Diseases of the skin and subcutaneous tissue
XIII    M00–M99 Diseases of the musculoskeletal system and connective tissue
XIV    N00–N99 Diseases of the genitourinary system
XV    O00–O99 Pregnancy, childbirth and the puerperium
XVI    P00–P96 Certain conditions originating in the perinatal period
XVII    Q00–Q99 Congenital malformations, deformations and chromosomal abnormalities
XVIII    R00–R99 Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified
XIX    S00–T98 Injury, poisoning and certain other consequences of external causes
XX    V01–Y98 External causes of morbidity and mortality
XXI    Z00–Z99Factors influencing health status and contact with health services
XXII    U00–U99 Codes for special purposes

 
 
TOP TEN CLASSES (Taken from the 50 returned from the 5 X 10 functions)

 watson.query.five.classifiers("bitten by a wild pig in the left leg")
    class           confidence
 1:   W55  0.33606352760420066
 2:   M79  0.21942966846914216
 3:   S90  0.20187063115504736
 4:   S72   0.1867607490106112
 5:   M02   0.1849542951462859
 6:   R62  0.18333693860407277
 7:   Z63  0.14295376020063674
 8:   S71  0.13195078900692148
 9:   T16  0.11516054234192707
10:   S59  0.09322628449385714
