# Set the Working Directory using setwd()
# data_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# Download and Unzip the Data into the working directory

# Install / Load the necessary packages
if (!require("data.table")) {
        install.packages("data.table")
}

if (!require("dplyr")) {
        install.packages("data.table")
}

library(data.table)
library(dplyr)

# Load all "Test" Datasets into R
test_subject    <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
test_X          <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
test_Y          <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE)


# Load all "Train" Datasets into R
train_subject   <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
train_X         <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE)
train_Y         <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE)

# Load Column Names into R
feature_cols    <- read.table("./UCI HAR Dataset/features.txt")
activity_cols   <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE)


#PART 1. Merges the training and the test sets to create one data set
subject         <- rbind(test_subject, train_subject)
activity        <- rbind(test_Y, train_Y)
features        <- rbind(test_X, train_X)

colnames(subject)  <- "Subject"
colnames(activity) <- "Activity"
colnames(features) <- t(feature_cols[2])

MergedData <- cbind(subject,activity,features)


#PART 2. Extracts only the measurements on the mean and standard deviation for each measurement 
Mean_STDEV <- grep(".*mean.*|.*std.*", names(MergedData), ignore.case=TRUE)

# PART 3. Uses descriptive activity names to name the activities in the data set
MergedData[, 2] <- activity_cols[MergedData[,2],2]
MergedData$Activity <- as.factor(MergedData$Activity)

# PART 4. Appropriately labels the data set with descriptive variable names
names(MergedData) <- gsub('tBody',"Body",names(MergedData))
names(MergedData) <- gsub('Acc', 'Acceleration', names(MergedData))
names(MergedData) <- gsub('std', 'StandardDeviation', names(MergedData))
names(MergedData) <- gsub('tGravity', 'Gravity', names(MergedData))

# PART 5. From the data set in step 4, creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject
# version 2 - added the following 2 lines to get around Error in model.frame.default
MergedData$Subject <- as.factor(MergedData$Subject)
MergedData <- data.table(MergedData)
#
tidydataset <- aggregate(. ~Subject + Activity, MergedData, mean)

write.table(tidydataset, file = "./tidy.txt", row.names = FALSE)


