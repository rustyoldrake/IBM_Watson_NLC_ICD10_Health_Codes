######################################################
### Experimental Code.  Experimental R Interface for IBM Watson
### NLC to help with INITIAL TRIAGE of Emails that may come into a bank or insurance company
### Focus: Natural Language Classifier - R Programming Language Interface
### GROUND TRUTH IS VERY LIGHT - HANDLE WITH CARE - was authored in 20 minutes and contains NO real world data
### Could be used to BOOTSTRAP actual data - best practices are to use REAL WORLD Data for training
### HANDBOOK Natural Language Classifier (NLC) Handbook: https://ibm.box.com/s/rdlog2sue79178816s0rabkbi7ifu5vg 
### Video #1 - Training - https://www.youtube.com/watch?v=nrD37M39QnA 
### Video #2 - Testing - https://youtu.be/kBx6reEj4Gg
### Training Data - Ground truth: https://github.com/rustyoldrake/NLC_ground_truth_wonderland/blob/master/ground_truth_gt_NLC_example_email_sort.csv
### This R code lives here https://github.com/rustyoldrake/NLC_ground_truth_wonderland
### NEW VIDEOS Part 1   https://www.youtube.com/watch?v=HC6O6HczqC0 - Part 2 - https://youtu.be/skWlP9U78rE 
#######################################################

library(RCurl) # install.packages("RCurl") # if the package is not already installed
library(httr)
library(data.table)
library(dplyr)
library(reshape2)
library(Rtts)
library(splitstackshape)
library(stringr)
library(splitstackshape)
library(tidyr)
library(XML)
library(png)

######### Housekeeping And Authentication 

setwd("/Users/ryan/Documents/Project ICD-Codes/") # Set working Directory
getwd()
#source("keys.r") ## KEYS has acutal username:password for each IBM service. Seperate R file looks sort of like below


# NLC CREDENTIALS

username_NLC <- "#####"
password_NLC = "#####"
username_password_NLC = paste(username_NLC,":",password_NLC,sep="")


## You will need to go to IBM Cloud / Bluemix and Create an NLC Service and GET SERVICE CREDENTIALS once it is active
username_password_NLC  # check you got this from NLC file
base_url_NLC = "https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers/"
getURL(base_url_NLC,userpwd = username_password_NLC )  # non essential , but checks if working /authenticated

###### FUNCTION CREATE NEW CLASSIFIER - post /v1/classifiers - Creates a classifier with CSV data ## URL below no "/" after base url
watson.nlc.createnewclassifier <- function(file,classifiername) {
  return(POST(url="https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers",
         authenticate(username_NLC,password_NLC),
         body = list(training_data = upload_file(file),
                     training_metadata = paste("{\"language\":\"en\",\"name\":",classifiername,"}",sep="") 
         )))}
###### end of function

###### FUNCTION - CHECK CLASSIFIER STATUS
watson.nlc.checkclassifierstatus <- function(classifier_id) {
  return(
    getURL(paste(base_url_NLC,classifier_id,sep=""),userpwd = username_password_NLC)
  )
}
### end of function


###### FUNCTION - DELETE CLASSIFIER - Receives name of Classifier to Kill; May not be able to do this until training complete
watson.nlc.deleteclassifier <- function(kill_classifier) {
  DELETE(url=(paste(base_url_NLC,kill_classifier,sep="")),authenticate(username_NLC,password_NLC))
}
 
### end of function

###### FUNCTION: ACCEPT QUERY & RETURN RESULT: CLASSIFIER and % FROM TEXT INPUT AND PROCESS TO LOOK GOOD
watson.nlc.processtextreturnclass <- function(classifier_id,query_text){
    query_text <- URLencode(query_text)
    data <- getURL(paste(base_url_NLC,classifier_id,"/classify","?text=", query_text,sep=""),userpwd = username_password_NLC)
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
  data <- getURL(base_url_NLC,userpwd = username_password_NLC )
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


username_password_NLC  # check you got this from NLC file
base_url_NLC = "https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers/"
getURL(base_url_NLC,userpwd = username_password_NLC )  # non essential , but checks if working /authenticated






##### ACTION: EXECUTE FUNCTION  TO KILL (!!!) DELETE (!!!) CLASSIFIER - WARNING
watson.nlc.listallclassifiers()  # inventory - what do we want to delete - classifier id
#kill <- "842a87x335-nlc-527"
# watson.nlc.deleteclassifier(kill)  ## CAREFUL HERE - UNCOMMENT TO KILL CLASSIFIER
watson.nlc.listallclassifiers()  # check it's gone

username_password_NLC  # check you got this from NLC file
base_url_NLC = "https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers/"
getURL(base_url_NLC,userpwd = username_password_NLC )  # non essential , but checks if working /authenticated




######################################################### END OF FUNCTION DECLARATIONS

######################################################### OK LETS DO STUFF

thefile <- "ICD-10-GT-2018-GROUPA-0to20k.csv" # 
thename <- "\"ICD-10-GT-2018-GROUPAA\""   #

thefile <- "ICD-10-GT-2018-GROUPB-20k-40k.csv" # 
thename <- "\"ICD-10-GT-2018-GROUPB\""   #

thefile <- "ICD-10-GT-2018-GROUPC-40k-60k.csv" # 
thename <- "\"ICD-10-GT-2018-GROUPC\""   #

thefile <- "ICD-10-GT-2018-GROUPD-60k-69k.csv" # 
thename <- "\"ICD-10-GT-2018-GROUPD\""   #

watson.nlc.createnewclassifier(thefile,thename)  # calls function, passes file and name from above, starts the magic. might take 2 to 20+ minutes depending on complexityclassifier_id" : "563C46x19-nlc-377",


###### ACTION: Create a new CLassifier!  (200 = Good outcome) - 
thename <- "\"ICD-10-GT-2018-GROUPA\""   #
thefile <- "ground_truth_gt_NLC_example_email_sort.csv" #  
watson.nlc.createnewclassifier(thefile,thename)  # calls function, passes file and name from above, starts the magic. might take 2 to 20+ minutes depending on complexityclassifier_id" : "563C46x19-nlc-377",


###### ACTION: Retrieve list of classifiers (NEAT VERSION) - oldest to newest
watson.nlc.listallclassifiers()  # not happy response if no classifiers (Blank) if blank, use below

## ARE WE READY?  (might take 10-15m or more if really complex - be patient for the magic!)
classifierA <- "51233dx385-nlc-22" #     ####  COPY PASTE * YOUR* CLASSIFIER HERE TO CHECK STATUS  ####
classifierB <- "511c9dx382-nlc-34" # 
classifierC <- "5120e7x384-nlc-38" # 
classifierD <- "511c9dx382-nlc-35" # 


watson.nlc.checkclassifierstatus(classifierA)
watson.nlc.checkclassifierstatus(classifierB)
watson.nlc.checkclassifierstatus(classifierC)
watson.nlc.checkclassifierstatus(classifierD)


### READY OR NOT?
# if new will say "not yet ready to accept classify requests" - once done in a few mintues will say
# "The classifier instance is now available and is ready to take classifier requests" - then you can submit query below


# LIGHT MANUAL TESTING
query <- "Slipped on ice.  Fractured skull"
watson.nlc.processtextreturnclass(classifierA,query)
watson.nlc.processtextreturnclass(classifierB,query)
watson.nlc.processtextreturnclass(classifierC,query)
watson.nlc.processtextreturnclass(classifierD,query)


four_scores <- function()
{
  ## gets each of four classifiers
  data_a <- watson.nlc.processtextreturnclass(classifierA,query)
  data_b <- watson.nlc.processtextreturnclass(classifierB,query)
  data_c <- watson.nlc.processtextreturnclass(classifierC,query)
  data_d <- watson.nlc.processtextreturnclass(classifierD,query)
  
  ## one ring to bind them all
  data <- rbind(data_a,data_b,data_c,data_d)
  
  ## sort decending
  data <- data[order(-confidence),] 
  head(data,10)
  return(head(data,12)) # return just top 12
}

four_scores()



query <- "Streptococcus pneumoniae"
four_scores()

query <- "left ear shot off with laser gun"
four_scores()

query <- "cat bite on the left leg"
four_scores()

query <- "bit on the ear from a horse"
four_scores()

query <- "rapid heart rate and chest pain"
four_scores()

query <- "skin rash due to exposure to poison ivy"
four_scores()

query <- "broken ankle from motorcycle accident"
four_scores()


