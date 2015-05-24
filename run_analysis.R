#Ensure to setwd() Working directory (Example in next line), this script assumes the working directory has a subfolder /data that contains the input files
#setwd("S:/Class/DataScienceCert/03_GetData/project1/SmartphoneActivity")

#load libraries into memory
library(dplyr)
library(data.table)

### READ data files into data tables ###
subject_train <- read.table("./data/subject_train.txt")
x_train <- read.table("./data/x_train.txt")
y_train <- read.table("./data/y_train.txt")
subject_test <- read.table("./data/subject_test.txt")
x_test <- read.table("./data/x_test.txt")
y_test <- read.table("./data/y_test.txt")
activity_labels <- read.table("./data/activity_labels.txt", header=FALSE, sep=" ")
#features <- read.table("./data/features.txt", header=FALSE, sep=" ")
features <- fread("./data/features.txt", header=FALSE, sep=" ") # Changed read.table to fread to enable %like% functionality

### combine data ###
#Combine Train data into one dataset
data <- cbind(subject_train,y_train)
data <- cbind(data,x_train)
#Combine Test data into one data set
testdata <- cbind(subject_test,y_test)
testdata <- cbind(testdata,x_test)
#Requirement #1: Merges the training and the test sets to create one data set.
#Combine Train and Test data into one dataset
data <- rbind(data,testdata)


#Requirement #4: Appropriately labels the data set with descriptive variable names. 
#Label the columns
colnames(data) <- c("Subject","Activity_Id",as.character(features$V2))
colnames(activity_labels) <- c("Activity_Id","Activity")

#Requirement #3: Uses descriptive activity names to name the activities in the data set
#Append Activity Name 
data <- merge(activity_labels,data) # Joins on only common column "Activity_Id"

#Free up memory #Remove objects from environment
rm(list=c("xtest","xtrain","y_test","y_train", "subject_test","subject_train", "testdata"))

#Requirement #2: Extracts only the measurements on the mean and standard deviation for each measurement.
indexOfMeanStdfeatures <- features[features$V2 %like% "mean" | features$V2 %like% "std"]$V1
indexOfMeanStdfeatures <- indexOfMeanStdfeatures + 3 #Adds an offset for Prepended 3 fields: {Activity_Id, Activity, Subject}
#Cleaned Data Set  # Selects {Subject, Activity, {Mean and Std columns}}
tidydata <- data[c(3,2,indexOfMeanStdfeatures)] 


#Requirement #5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
summarydata <- tidydata %>% group_by(Subject, Activity) %>% summarise_each(funs(mean))

#Writes teh summarydata to a "Pipe-delimited" text file
write.table(summarydata, file="./data/summarydata.txt",sep="|",row.name=FALSE)
