# Obtains subject activity data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip .
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names. 
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity 
# and each subject.

# Run the whole program by running the runMain() function (which then calls all the other functions, in correct order).

# will need the summarise_each function in this package
library(dplyr)

# set working path (for consistency)
setwd("C:/src/coursera/data_cleaning/course_project/")


# Downloads the data, and saves to the data directory.  Creates the directory if doesn't already exist.
# Unzips and extracts the data files.
downloadData <- function() {
	# create data directory to put our zip file into
	if (!file.exists("data")) {
		dir.create("data")
	}
	
	# only re-download if zip files isn't already there
	if (!file.exists("./data/wearable.zip")) {
		# record the output for notes after every download
		date_downloaded <- date()
		print(paste("Date Downloaded: ", date_downloaded))
		
		
		# %2F is _
		get_file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
		save_file_path <- "./data/wearable.zip"
		
		## error 127 means command (curl) not found.  so working around with Internet2 and method=internal on windows, and method=wget on linux
		## download.file(url=get_file_url, destfile=save_file_path, method="curl")
		setInternet2(use = TRUE)
		download.file(url=get_file_url, destfile=save_file_path, method="internal")
		
		# make a directory called "UCI HAR Dataset" with all the zip content extracted into it
		unzip(save_file_path, exdir="./data")
	}
	
	#print(list.files("./data"))  # for a debug look-see
} # end downloadData

	

# Reads the data into data frames, and merges the train and test files.
combineData <- function() {
	# contains two columns: a numeric index, and a word measurement label
	observation_labels_all <- read.table("./data/UCI HAR Dataset/features.txt")  # 561 by 2 file
	
	# 561 columns of observation data from the 30% of subjects selected as test data.
	# The columns are unlabeled.  Labels are separate, in the features.txt file.
	x_test_all <- read.table("./data/UCI HAR Dataset/test/X_test.txt")  # 2947 by 561 file
	
	# a single column of numeric labels, ranging from 1-6, one label for each observation.  
	# 1-6 represent: 1-WALKING, 2-WALKING_UPSTAIRS, 3-WALKING_DOWNSTAIRS, 4-SITTING, 5-STANDING, 6-LAYING
	y_test_all <- read.table("./data/UCI HAR Dataset/test/y_test.txt")  # 2947 by 1 file
	
	# Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.
	subject_test_all <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")  # 2947 by 1 file

	# 561 columns of observation data from the 70% of subjects selected as training data.
	# The columns are unlabeled.  Labels are separate, in the features.txt file.
	x_train_all <- read.table("./data/UCI HAR Dataset/train/X_train.txt")  # 7352 by 561 file

	# a single column of numeric labels, ranging from 1-6, one label for each observation.  
	# 1-6 represent: 1-WALKING, 2-WALKING_UPSTAIRS, 3-WALKING_DOWNSTAIRS, 4-SITTING, 5-STANDING, 6-LAYING
	y_train_all <- read.table("./data/UCI HAR Dataset/train/y_train.txt")  # 7352 by 1 file
	
	# Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.
	subject_train_all <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")  # 7352 by 1 file
	
	# add the descriptive column labels
	colnames(x_test_all) <- observation_labels_all[,2]
	colnames(x_train_all) <- observation_labels_all[,2]
	
	# add the columns of subject and activity labels to each observation data frame
	x_test_all["activity"] <- y_test_all
	x_test_all["subject"] <- subject_test_all
	
	# add the columns of subject and activity labels to each observation data frame
	x_train_all["activity"] <- y_train_all
	x_train_all["subject"] <- subject_train_all

	
	# now combine the test and train datasets
	combined_data <- rbind(x_test_all, x_train_all)  # 10299 by 563 data frame

	# replace activity numbers with human-readable words
	combined_data$activity[combined_data$activity == 1] <- "WALKING"
	combined_data$activity[combined_data$activity == 2] <- "WALKING_UPSTAIRS"
	combined_data$activity[combined_data$activity == 3] <- "WALKING_DOWNSTAIRS"
	combined_data$activity[combined_data$activity == 4] <- "SITTING"
	combined_data$activity[combined_data$activity == 5] <- "STANDING"
	combined_data$activity[combined_data$activity == 6] <- "LAYING"
	
	# create another column that would combine a descriptive activity name and a subject number
	# don't need this any more, but keeping for reference
	#combined_data$activity_subject = paste(combined_data$activity, combined_data$subject, sep="_")
	
	return(combined_data)
} # end combineData



# Extracts only the measurements on the mean and standard deviation for each measurement. 
extractWantedColumns <- function(combined_data) {
	# get the column names
	column_names <- colnames(combined_data)
	
	# makes an index of columns whose names interest us
	# We can choose to look for mean() and std(), rather than mean and std, escaping the parentheses with \\, like: 
	# grepl("mean\\(\\)",...) .  This would produce fewer columns.  I like keeping stuff like "gravityMean".
	columns_to_keep <-  grep("mean|std|activity|subject", column_names)
	
	combined_data <- combined_data[columns_to_keep]
	
	return(combined_data)
}



# Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
computeAverages <- function(meanStandardData) {
	# want something like: computedAverages <- summarize(meanStandardData, meanStandardData["activity"]:meanStandardData["subject"], mean)
	# the summarise_each function lets us do that.
	tidyAveragedData <- meanStandardData %>% group_by(activity, subject) %>% summarise_each(funs(mean))
	return(tidyAveragedData)
}



# Writes out the tidy data set and saves as its own file.
writeResult <- function(computedAverages) {
	# write the tidy results to an output file
	write.table(computedAverages, file = "./data/UCI HAR Dataset/tidy_averaged_data.txt", row.name = FALSE)
}



# Runs through all of the functions of obtaining, cleaning, and processing the subject activity dataset.
runMain <- function() {
	downloadData()
	
	combinedData <- combineData()
	
	meanStandardData <- extractWantedColumns(combinedData)

	computedAverages <- computeAverages(meanStandardData)

	writeResult(computedAverages)
}

