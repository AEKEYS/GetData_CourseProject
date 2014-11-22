# You should create one R script called run_analysis.R that does the following. 

## Merges the training and the test sets to create one data set.

getData <- function(file, url) {
    # Gets file from web and unzips it into working directory
    found <- F
    if (file %in% dir()) {
        found <- T
    }
    if (!found) {
        download.file(url, "tmp.zip", method = "curl")
        unzip("tmp.zip", unzip = "internal")
        unlink("tmp.zip")
    }
}

getData("UCI HAR Dataset","https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")

featureNames <- read.table("./UCI Har Dataset/features.txt",
                           stringsAsFactors = FALSE)

trainX <- read.table("./UCI HAR Dataset/train/X_train.txt",
                    header=FALSE,
                    sep = "",
                    col.names = featureNames[,2],
                    colClasses = "numeric")

trainY <- read.table("./UCI HAR Dataset/train/y_train.txt",
                     header = FALSE,
                     sep = "",
                     col.names = "activity",
                     colClasses = "integer")

trainSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt",
                            sep = "",
                            col.names="subject",
                            colClasses = "integer")

testX <- read.table("./UCI HAR Dataset/test/X_test.txt",
                   header=FALSE,
                   sep="",
                   col.names = featureNames[,2],
                   colClasses = "numeric")

testY <- read.table("./UCI HAR Dataset/test/y_test.txt",
                    header=FALSE,
                    col.names = "activity",
                    sep="",
                    colClasses = "integer")

testSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt",
                           col.names = "subject",
                           colClasses="integer")

trainX <- cbind(trainX, trainY) #add integer activity labels
trainX <- cbind(trainSubjects,trainX) #add subject labels

testX <- cbind(testX,testY) #add integer activity labels
testX <- cbind(testSubjects,testX) #add subject labels

data <- rbind(trainX,testX) #combine data sets by row

rm(testX);rm(trainX);rm(testY);rm(trainY);rm(featureNames);rm(testSubjects);rm(trainSubjects) #remove from memory, no longer needed

## Extracts only the measurements on the mean and standard deviation for each measurement. 

# per CodeBook, each of the following measures has an X, Y, and Z measurement and mean and std

measurements <- c("tBodyAcc",
                  "tGravityAcc",
                  "tBodyAccJerk",
                  "tBodyGyro",
                  "tBodyGyroJerk",
                  "fBodyAcc",
                  "fBodyAccJerk",
                  "fBodyGyro")

# I will build the feature names to extract those features that are means or standard deviations

axes <- c("X","Y","Z")
methods <- c("mean..","std..")

# populate a list with the names of features to extract
features2extract <- list()

for (measure in measurements){
    for (axis in axes){
        for (m in methods){
            features2extract <- c(features2extract,paste(measure,
                                                         m,
                                                         axis,
                                                         sep = ".") # names didn't accept hyphens
            )
        }
    }
}

# per CodeBook, each of these measures have a mean and std but no axis measurement
# So, I will build feature names to extract these as well.

measurements2 <- c("tBodyAccMag",
                   "tGravityAccMag",
                   "tBodyAccJerkMag",
                   "tBodyGyroMag",
                   "tBodyGyroJerkMag",
                   "fBodyAccMag",
                   "fBodyBodyAccJerkMag", #the extra "body" is an anomaly
                   "fBodyBodyGyroMag", #must have been a typo in the orig data
                   "fBodyBodyGyroJerkMag") #this one too. weird.

for (measure in measurements2){
    for (m in methods){
        features2extract <- c(features2extract,paste(measure,
                                                     m,
                                                     sep = "."))
    }
}

features2extract <- c(features2extract, "activity","subject") #also need the activity and subject labels

features2extract <- unlist(features2extract) #character vector

library(dplyr) #load package

downSelected <- tbl_df(data) #dplyr expects data as a 'data frame tbl'

downSelected <- select(downSelected, which(names(downSelected) %in% features2extract)) #extracts wanted features

rm(data) # done with this, clear memory

## Uses descriptive activity names to name the activities in the data set

activityNames <- read.table("./UCI Har Dataset/activity_labels.txt",
                           stringsAsFactors = FALSE)

downSelected$activity <- factor(downSelected$activity)
levels(downSelected$activity) <- activityNames[,2] # give levels descriptive names

## Appropriately labels the data set with descriptive variable names. 

# already accomplished when data was read in (see col.names argument in calls to read.table)

## From the data set in step 4, creates a second, independent tidy data set with 
#the average of each variable 
#for each activity 
#and each subject.

library(reshape2)
Molten <- melt(downSelected,id=c("activity","subject")) # stack the columns as variables to "melt" data set
result <- dcast(Molten, subject + activity ~ variable, fun = mean) # group by subject and activity, take mean of each variable

#export Tidy Data
write.table(result,file = "./myTidyData.txt",
            row.names=FALSE)


