if(!file.exists("./UCI HAR Dataset")){dir.create("./UCI HAR Dataset")}
fileUrl <- fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "./UCI HAR Dataset/Dataset.zip",mode = "wb")

unzip("./UCI HAR Dataset/Dataset.zip")


## Reading the global index files: activities and features
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
features <- read.table("./UCI HAR Dataset/features.txt")

## Reading the TRAIN files
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")

names(trainActivities) <- "activities"
names(trainSubjects) <- "subjects"

Selected_features <- grep("std|mean\\(\\)", features[,2])
## toma los índices de las variables con la palabra mean() o std
## se seleccionaron 66 variabes

train <- read.table("UCI HAR Dataset/train/X_train.txt")[Selected_features]

## clean variable names
features_names <- features[Selected_features,2]
features_names <- gsub('[()]','', features_names)
features_names <- gsub('mean','Mean', features_names)
features_names <- gsub('std','Std', features_names)
features_names <- gsub('-','', features_names)
names(train) <- features_names

## put together all train tables
TotTrain <- cbind(trainSubjects,trainActivities,train)
TotTrain$type <- "train"
## (I add this column because I imagine that in a future you might want
## to know which values are from the train or test session)

## Reading the TEST set
testActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
names(testActivities) <- "activities"
names(testSubjects) <- "subjects"

test <- read.table("UCI HAR Dataset/test/X_test.txt")[Selected_features]

## clean variable names
names(test) <- features_names

## put together all test tables
TotTest <- cbind(testSubjects, testActivities,test)
TotTest$type <- "test"
## idem

## put together both tables
TrainTest <- rbind(TotTrain,TotTest)

## Change activity number for names and convert to factors
TrainTest$activities <- factor(TrainTest$activities, labels=tolower(activityLabels$V2))
TrainTest$subjects <- as.factor(TrainTest$subjects)

## melt the dataset and the recast it as we want and write it into a file
library(reshape2)
tt_melt <- melt(TrainTest,id=c('subjects','activities','type'), measure.vars= names(TrainTest)[3:68])
tt_mean <- dcast(tt_melt, subjects + activities ~ variable, mean)
write.table(tt_mean, "tt_mean.txt", row.names=FALSE)
