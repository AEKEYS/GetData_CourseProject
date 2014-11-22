GetData_CourseProject
=====================

This project is for the Johns Hopkins University's ["Getting and Cleaning Data"](https://www.coursera.org/course/getdata) offered through Coursera.

#Objective
This project uses data from a [UCI Machine Learning Repository initiative](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) and transforms it into [Tidy Data](http://vita.had.co.nz/papers/tidy-data.pdf).

The task was to:

1. Merge the training and the test sets to create one data set.
2. Extract only the measurements on the mean and standard deviation for each measurement. 
3. Use descriptive activity names to name the activities in the data set
4. Appropriately label the data set with descriptive variable names. 
5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

#Included files
- 'README.md'  
- 'run_analysis.R': an R script that performs the getting and cleaning operations.  
- 'myTidyData.txt': Tidy Data as output by run_analysis.R
- 'CodeBook.txt': file describing the variables in the generated Tidy Data.

#How it works
The run_analysis.R walks the user step-by-step through the process of downloading the original zip file, unpacking it, and loading the appropriate files.

Then, the script joins and labels multiple text files to create one data frame.

Next, the script selects only those variables from the original data that have mean and standard deviation measurements. This "down selected" data frame is then melted into a tidy data frame where each row is an observation and each column represents one variable.  

This "molten" data frame is then recast into an exportable tidy data text file ("myTidyData.txt") that groups the data by subject and activity.  The values are the average of each measurement.