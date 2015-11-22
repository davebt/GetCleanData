#####################################################################################################
# The purpose of this project is to demonstrate your ability to collect, work with,                 # 
# and clean a data set. The goal is to prepare tidy data that can be used for later analysis.       #
# You will be graded by your peers on a series of yes/no questions related to the project.          #
# You will be required to submit:                                                                   # 
#     1) a tidy data set as described below,                                                        # 
#     2) a link to a Github repository with your script for performing the analysis, and            #
#     3) a code book that describes the variables, the data, and any transformations or             #
#          work that you performed to clean up the data called CodeBook.md.                         #
#          You should also include a README.md in the repo with your scripts.                       #
#          This repo explains how all of the scripts work and how they are connected.               #
#                                                                                                   #
# One of the most exciting areas in all of data science right now is wearable computing -           #
#     see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to      #
#     develop the most advanced algorithms to attract new users. The data linked to from the        #
#     course website represent data collected from the accelerometers from the Samsung Galaxy S     #
#     smartphone. A full description is available at the site where the data was obtained:          #
#                                                                                                   #
#     http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones           #
#                                                                                                   #
# Here are the data for the project:                                                                #
#                                                                                                   #
#     https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip        #
#                                                                                                   #
# You should create one R script called run_analysis.R that does the following.                     #
# 1. Merges the training and the test sets to create one data set.                                  #
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.        #
# 3. Uses descriptive activity names to name the activities in the data set                         #
# 4. Appropriately labels the data set with descriptive variable names.                             #
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of   #
# each variable for each activity and each subject.                                                 #
#####################################################################################################

###########
# Preface #
###########

# i. Set required packages
library(plyr)
library(dplyr)
library(reshape2)

# ii. Clean up the workspace
rm(list=ls())

# iii. set working directory to location of unzipped UCI HAR dataset
#start.wd <- getwd()
#setwd('/Users/David/Documents/Coursera/GetCleanData/')

# iv. Download the data
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="auto", mode = "wb")

# v. Unzip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# vi. Unzipped files are in the folder UCI HAR Dataset. List the files
relpath <- file.path("./data", "UCI HAR Dataset")
datafiles <- list.files(relpath, recursive = TRUE)
datafiles

####################################################################
# 1. Merges the training and the test sets to create one data set. #
####################################################################

# 1.1. Read the Activity files
dataActivityTest  <- read.table(file.path(relpath, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(relpath, "train", "Y_train.txt"),header = FALSE)

# 1.2. Read the Subject files
dataSubjectTrain <- read.table(file.path(relpath, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(relpath, "test" , "subject_test.txt"),header = FALSE)

# 1.3. Read the Features files
dataFeaturesTest  <- read.table(file.path(relpath, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(relpath, "train", "X_train.txt"),header = FALSE)

# 1.4. Look at the properties of the variables
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

# 1.5. Concatenate the data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity <- rbind(dataActivityTrain, dataActivityTest)
dataFeatures <- rbind(dataFeaturesTrain, dataFeaturesTest)
names(dataSubject) <- c("subject")
names(dataActivity) <- c("activity")
str(dataSubject)
str(dataActivity)
str(dataFeatures)

##############################################################################################
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. #
##############################################################################################

# 2.1. Subset Name of Features by measures on mean and standard deviation
features <- read.table(file.path(relpath, "features.txt"),head=FALSE)
features[,2] <- as.character(features[,2])
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

# 2.2. Subset the data frame Data by seleted names of Features
dataFeatures <- subset(dataFeatures,select=featuresWanted)
names(dataFeatures) <- featuresWanted.names

# 2.3. Check the structure of the data frame
str(dataFeatures)

#############################################################################
# 3. Uses descriptive activity names to name the activities in the data set #
#############################################################################

# 3.1. Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(relpath, "activity_labels.txt"),header = FALSE)

# 3.2. Factorize variable activity in the dataframe dataActivity using descriptive names
dataActivity$activity <- factor(dataActivity$activity, levels = activityLabels[,1], labels = activityLabels[,2])
dataSubject$subject <- as.factor(dataSubject$subject)

# 3.3. Check
head(dataActivity$activity,30)

# 3.4. Merge all the datasets together into Data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

# 3.5. Check the full data set
head(Data,30)
str(Data)

#########################################################################
# 4. Appropriately labels the data set with descriptive variable names. #
#########################################################################

# In the former part, variables activity and subject and names of the activities have been labelled
# using descriptive names.In this part, Names of Feteatures will labelled using descriptive variable names.

# prefix t is replaced by time
# Acc is replaced by Accelerometer
# Gyro is replaced by Gyroscope
# prefix f is replaced by frequency
# Mag is replaced by Magnitude
# BodyBody is replaced by Body

# 4.1. Substitute strings to give appropriate names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

# 4.2. Check
names(Data)

############################################################################################################
# 5. Create a second, independent tidy data set with the average of each variable by activity and subject. #
############################################################################################################

# 5.1. Melt the data by subject and activity
Data.melted <- melt(Data, id = c("subject", "activity"))

# 5.2. dcast the data back using the variable mean
Data.mean <- dcast(Data.melted, subject + activity ~ variable, mean)
head(Data.mean,6)

# 5.3. Write the tidied and summarized data to a text file
write.table(Data.mean, file = "tidydata.txt",row.name=FALSE)

############
# Postface #
############

# i. reset working directory to initial directory
#setwd(start.wd)