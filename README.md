---
title: "README"
author: "gothamgreensoftware"
date: "Thursday, March 19, 2015"
output: html_document
---

### How To Use
To run the whole program by running the runMain() function (which then calls all the other functions, in correct order).
You can also run the separate parts of the program, by calling individual functions.


### Environment Requirements
This program uses the dplyr package for its summarise_each function.  You must have the dplyr package installed.


### Function List and Description
**downloadData()** 
Downloads the data, and saves to the 'data' directory.  Creates the directory if doesn't already exist.  
Only downloads if the zip file isn't already on local drive.
Unzips and extracts the data files into 'data/UCI HAR Dataset/'.  
URL used for download is: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip .


**combineData()**
Reads the 'data/UCI HAR Dataset/' contents and creates a data frame that contains the merged training and test data.
Adds in columns that identify the activity performed and the id of the subject performing it.
Replaces activity numbers with human-readable words (ex.: '1' becomes 'WALKING').


**extractWantedColumns()**
Makes an index of the columns whose names interest us (for this assignment, it's columns containing mean and standard derivation measurements).
Includes meanFreq columns, which is not required, but a choice I made.
Uses the newly-learned 'grep' function to do this:
```{r}
columns_to_keep <-  grep("mean|std|activity|subject", column_names)
```
Creates a new data frame that contains only the activity, subject, and the wanted measurement columns.


**computeAverages()**
Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
The data set is made tidy by the following properties:
Each variable is in its own column.
Each observation (in this case, computed mean average) is in its own row.
Data is appropriately labeled with descriptive variable names.
Uses the newly-learned 'summarise_each' function in the 'dplyr' to do this:
```{r}
tidyAveragedData <- meanStandardData %>% group_by(activity, subject) %>% summarise_each(funs(mean))
```


**writeResult()**
Writes the passed-in data frame out to a file at './data/UCI HAR Dataset/tidy_averaged_data.txt' .


**runMain()**
Runs through all of the functions of obtaining, cleaning, and processing the subject activity dataset.



