######################################################
### Experimental Code.  Experimental R Interface for IBM Watson Services -
### Focus: Natural Language Classifier - R Programming Language Interface
### Playing with ICD Codes - multiple classifiers - proof of concept (not optimized, and no pre- or post- classifiers in this example)
###################################################### 

library(RCurl) # install.packages("RCurl") # if the package is not already installed
library(httr)
library(XML)
library(data.table)
library(reshape2)
library(tidyr)
library(dplyr)
library(stringr)
library(splitstackshape)
 

# ICD DEMO - Ryans' Service - will delete Jan 31 2016
username = "c18631c8-ba0c-47e6-YOUR-USERNAME"
password = "YOUR_PASSWORD"
username_password = paste(username,":",password)

######### Housekeeping And Authentication 
setwd("/Users/ryan/Documents/Project ICD-Codes")
getwd()
base_url = "https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers/"
getURL(base_url,userpwd = username_password ) 


###### FUNCTION CREATE NEW CLASSIFIER - post /v1/classifiers - Creates a classifier with CSV data ## URL below no "/" after base url
watson.nlc.createnewclassifier <- function(file,classifiername) {
  return(POST(url="https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers",
         authenticate(username,password),
         body = list(training_data = upload_file(file),
                     training_metadata = paste("{\"language\":\"en\",\"name\":",classifiername,"}",sep="") 
         )))}
###### end of function

###### FUNCTION - CHECK CLASSIFIER STATUS
watson.nlc.checkclassifierstatus <- function(classifier_id) {
  return(
    getURL(paste(base_url,classifier_id,sep=""),userpwd = username_password)
  )
}
### end of function


###### FUNCTION - DELETE CLASSIFIER - Receives name of Classifier to Kill; May not be able to do this until training complete
watson.nlc.deleteclassifier <- function(kill_classifier) {
  DELETE(url=(paste(base_url,kill_classifier,sep="")),authenticate(username,password))
}
 
### end of function

###### FUNCTION: ACCEPT QUERY & RETURN RESULT: CLASSIFIER and % FROM TEXT INPUT AND PROCESS TO LOOK GOOD
watson.nlc.processtextreturnclass <- function(classifier_id,query_text){
    query_text <- URLencode(query_text)
    data <- getURL(paste(base_url,classifier_id,"/classify","?text=", query_text,sep=""),userpwd = username_password)
    data <- as.data.frame(strsplit(as.character(data),"class_name"))
    data <- data[-c(1), ] # remove dud first row
    data <- gsub("[{}]","", data)
    data <- gsub("confidence","", data)
    data <- data.frame(matrix(data))
    setnames(data,("V1"))
    data$V1 <- gsub("\"","", data$V1)
    data$V1 <- gsub(":","", data$V1)
    data$V1 <- gsub("]","", data$V1)
    data <- cSplit(data, 'V1', sep=",", type.convert=FALSE)
    setnames(data,c("class","confidence"))
  return(data) }
### end of function
 
###### FUNCTION: LIST ALL CLASSIFIERS AND RETURN NEAT LIST
watson.nlc.listallclassifiers <- function(){ 
  data <- getURL(base_url,userpwd = username_password )
  data <- as.data.frame(strsplit(as.character(data),"classifier_id"))
  data <- data[-c(1), ] # remove dud first row
  data <- data.frame(matrix(data))
  colnames(data) <- "V1"
  data$V1 <- gsub("[{}]","", data$V1)
  data$V1 <- gsub("]","", data$V1)
  data$V1 <- gsub("\"","", data$V1)
  data$V1 <- gsub("name:","", data$V1)
  data$V1 <- gsub(":","", data$V1)
  data <- cSplit(data, 'V1', sep=",", type.convert=FALSE)
  data[,c(2,4)] <- NULL
  data <- as.data.table(data)
  setnames(data,c("classifier","name","date_created"))
  data <- data[order(date_created),] 
  return(data)
}

##### ACTION: EXECUTE FUNCTION  TO KILL (!!!) DELETE (!!!) CLASSIFIER - WARNING
watson.nlc.listallclassifiers()  # inventory - what do we want to delete - classifier id
kill <- "563C46x19-nlc-382"
watson.nlc.deleteclassifier(kill)
watson.nlc.listallclassifiers()  # check it's gone
## More NLC API DOCS here: https://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/natural-language-classifier/api/v1/#authentication


######################################################### END OF FUNCTION DECLARATIONS
######## OK - let's do stuff!



###### ACTION: Create a new CLassifier!  (200 = Good outcome) - 
####### THESE ARE BIG - TAKES A WHILE TO BE READY AND AVAILABLE
thename <- "\"ILC-Medical-Classifier-ILC-GT-AA\""   
thefile <- "ICD-10-GT-AA.csv" # 
watson.nlc.createnewclassifier(thefile,thename)  # calls function, passes file and name from above, starts the magic. might take 2 to 20+ minutes depending on complexityclassifier_id" : "563C46x19-nlc-377",
#"classifier_id" : "563C46x19-nlc-472",
#"name" : "ILC-Medical-Classifier-ILC-GT-AA",

thename <- "\"ILC-Medical-Classifier-ILC-GT-BB\""   
thefile <- "ICD-10-GT-BB.csv" #
watson.nlc.createnewclassifier(thefile,thename) 

thename <- "\"ILC-Medical-Classifier-ILC-GT-CC\""   
thefile <- "ICD-10-GT-CC.csv" #
watson.nlc.createnewclassifier(thefile,thename) 

thename <- "\"ILC-Medical-Classifier-ILC-GT-DD\""   
thefile <- "ICD-10-GT-DD.csv" 
watson.nlc.createnewclassifier(thefile,thename) 

thename <- "\"ILC-Medical-Classifier-ILC-GT-EE\""   
thefile <- "ICD-10-GT-EE.csv" 
watson.nlc.createnewclassifier(thefile,thename) 

## if new will say "not yet ready to accept classify requests" 
## "The classifier instance is now available and is ready to take classifier requests" - then you can submit query below
## takes a while (hours for largest ones)

###### ACTION: Retrieve list of classifiers (NEAT VERSION) - oldest to newest
watson.nlc.listallclassifiers()  # not happy response if no classifiers (Blank) if blank, use below

#4:  563C46x20-nlc-381 name  ILC-Medical-Classifier-ILC-GT-DD-SHORT created  2016-01-20T052335.865Z
#5:  563C46x20-nlc-382       name  ILC-Medical-Classifier-ILC-GT-EE created  2016-01-20T052510.412Z
#6:  563C46x19-nlc-472       name  ILC-Medical-Classifier-ILC-GT-AA created  2016-01-20T141505.228Z
#7:  563C46x19-nlc-473        name  ILC-Medical-Classifier-ILC-GT-B created  2016-01-20T141523.320Z
#8:  563C46x19-nlc-474       name  ILC-Medical-Classifier-ILC-GT-CC created  2016-01-20T141549.902Z

#getURL(base_url,userpwd = username_password ) #not formatted, see below for formatting

classifierA <- "563C46x19-nlc-472" #       name  ILC-Medical-Classifier-ILC-GT-AA created  2016-01-20T141505.228Z
classifierB <- "563C46x19-nlc-473" #        name  ILC-Medical-Classifier-ILC-GT-B created  2016-01-20T141523.320Z
classifierC <- "563C46x19-nlc-474" #       name  ILC-Medical-Classifier-ILC-GT-CC created  2016-01-20T141549.902Z
classifierD <- "563C46x20-nlc-381" #       name ILC-Medical-Classifier-ILC-GT-DD
classifierE <- "563C46x20-nlc-382" #       name  ILC-Medical-Classifier-ILC-GT-EE created  2016-01-20T052510.412Z

watson.nlc.checkclassifierstatus(classifierA)
watson.nlc.checkclassifierstatus(classifierB)
watson.nlc.checkclassifierstatus(classifierC)
watson.nlc.checkclassifierstatus(classifierD)
watson.nlc.checkclassifierstatus(classifierE)
#"The classifier instance is now available and is ready to take classifier requests.\"\n}"

### Function to query all five classifiers (update later)
watson.query.five.classifiers <- function(query){ 
  A <- watson.nlc.processtextreturnclass(classifierA,query)
  B <- watson.nlc.processtextreturnclass(classifierB,query)
  C <- watson.nlc.processtextreturnclass(classifierC,query)
  D <- watson.nlc.processtextreturnclass(classifierD,query)
  E <- watson.nlc.processtextreturnclass(classifierE,query)
  result <- data.table(rbind(A,B,C,D,E))
  return(result[order(-confidence)])
}


###### THIS IS FOR DISCUSSION PURPOSES ONLY - THE CLASSIFIER HAS NOT BEEN OPTIMIZED AND SHOULD BE USED IN COMBINATION WITH OTHER NLC.S


##### ACTION: LET'S GO!  SUBMIT TEXT AND CLASSIFY, RETURN CLASS / %
watson.query.five.classifiers("bitten by a wild pig in the left leg")
# Bitten by pig, initial encounter	W5541XA-Bitten by pig, initial encoun

watson.query.five.classifiers("a dog bite on the right ankle")
# Unspecified open wound, right ankle, initial encounter	S91001A-Unspecified open wound, right
# Bitten by dog, initial encounter	W540XXA-Bitten by dog, initial encoun

watson.query.five.classifiers("rubber bullet lodged in the left thigh")
#Superficial foreign body, left thigh, subsequent encounter	S70352D-Superficial foreign body, lef
#Legal intervention involving injury by rubber bullet, bystander injured, initial encounter	Y35042A-Legal intervention involving

watson.query.five.classifiers("child's left hand got caught in a snowblower")
# Contusion of left hand, initial encounter	S60222A-Contusion of left hand, initi
# Delayed milestone in childhood	R620-Delayed milestone in childhoo
# Inadequate parental supervision and control	Z620-Inadequate parental supervisi

watson.query.five.classifiers("alcohol poisoning")
# Alcohol dependence with intoxication, uncomplicated	F10220-Alcohol dependence with intox
# 49% Toxic effect of ethanol, accidental (unintentional), initial encounter	T510X1A-Toxic effect of ethanol, acci

watson.query.five.classifiers("left ear shot off with a laser weapon by foreign invaders")
# 82% Foreign body in left ear, initial encounter	T162XXA-Foreign body in left ear, ini
# 54% Unspecified open wound of left ear, initial encounter	S01302A-Unspecified open wound of lef
# 11% Exposure to laser radiation, initial encounter	W902XXA-Exposure to laser radiation,




##################################################################



