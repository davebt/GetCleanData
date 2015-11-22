---
title: "Getting and Cleaning Data Project"
author: "David Holland"
date: "November 21, 2015"
output: html_document
---

##Introduction

This is an R Markdown document produced as a codebook to accompany the R script file for the John Hopkins Getting and Cleaning Data course project. The R script, `run_analysis.R` peforms the following functions.
i. Preface - prepares the environment, activates the required packages, downloads the source data and unzips it.
1. Merges the training and test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## i. Preface
This section clears the workspace, finds the starting directory and sets the working directory for the project. This section also downloads the data using download.file method using 'auto' rather than 'curl' due to issues with curl on Windows 10 in RStudio.
```{r}
library(plyr)
library(dplyr)
library(reshape2)

rm(list=ls())

start.wd <- getwd()
setwd('/Users/David/Documents/Coursera/GetCleanData/')

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="auto", mode = "wb")

unzip(zipfile="./data/Dataset.zip",exdir="./data")

relpath <- file.path("./data", "UCI HAR Dataset")
datafiles <- list.files(relpath, recursive = TRUE)
datafiles
```
The file is then unzipped and the list of files created is stored in a variable 'datafiles'

## 1. Merges the training and the test sets to create one data set.
The read.table method is used to import the contents of the 'Activity' files (`Y_test.txt` & `Y_train.txt`), the 'Subject' files (`subject_test.txt` & `subject_train.txt`) and the 'Features' files (`X_test.txt` & `X_train.txt`). These six data sets are then concatenated using 'rbind' to form three new merged data sets and real names are given to the 'subject' and 'activity' data frames.

```{r}
dataActivityTest  <- read.table(file.path(relpath, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(relpath, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(relpath, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(relpath, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(relpath, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(relpath, "train", "X_train.txt"),header = FALSE)
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity <- rbind(dataActivityTrain, dataActivityTest)
dataFeatures <- rbind(dataFeaturesTrain, dataFeaturesTest)
names(dataSubject) <- c("subject")
names(dataActivity) <- c("activity")

str(dataSubject)
str(dataActivity)
str(dataFeatures)
```

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
The `features.txt` file is read into the environment and the `grep` command is used to define the wanted means and standard deviations. This opportunity was also taken to tidy up the measures names using the `gsub` command.
```{r}
features <- read.table(file.path(relpath, "features.txt"),head=FALSE)
features[,2] <- as.character(features[,2])
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)
dataFeatures <- subset(dataFeatures,select=featuresWanted)
names(dataFeatures) <- featuresWanted.names
```
```{r}
str(dataFeatures)
```

## 3. Uses descriptive activity names to name the activities in the data set.
The various activity labels are read into the environment and then used as a factor to apply the descriptive names against the activities. The three data sets of `dataSubject`, `dataActivity` and `dataFeatures` are then all combined into a single data set called `Data` and we then check the full data set.

```{r}
activityLabels <- read.table(file.path(relpath, "activity_labels.txt"),header = FALSE)
dataActivity$activity <- factor(dataActivity$activity, levels = activityLabels[,1], labels = activityLabels[,2])
str(dataActivity)

dataSubject$subject <- as.factor(dataSubject$subject)
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)
str(Data)
```

## 4. Appropriately labels the data set with descriptive variable names.
In the former part, variables activity and subject and names of the activities have been labelled using descriptive names.In this part, Names of 'Features' will labelled using descriptive variable names using the `gsub` command.

. prefix t is replaced by time
. Acc is replaced by Accelerometer
. Gyro is replaced by Gyroscope
. prefix f is replaced by frequency
. Mag is replaced by Magnitude
. BodyBody is replaced by Body

```{r}
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
names(Data)
```

## 5. Create a second, independent tidy data set with the average of each variable by activity and subject.
In this section the `reshape2` package functions of `melt` and `dcast` are used to melt the data down by 'subject' and 'activity' and then cast the molten data set back into a data frame by the variable mean. This is then exported to a text file `tidydata.txt` using the `write.table` command.
```{r}
Data.melted <- melt(Data, id = c("subject", "activity"))
Data.mean <- dcast(Data.melted, subject + activity ~ variable, mean)
head(Data.mean,6)
write.table(Data.mean, file = "tidydata.txt",row.name=FALSE)
```

## ii. Postface
Finally the working directory is reset to the original directory.
```{r}
setwd(start.wd)
```