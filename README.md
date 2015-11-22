# GetCleanData
Course Project for Coursera Getting and Cleaning Data (John Hopkins Data Science)

This repo contains a CodeBook `CodeBook.md` that explains the process behind the 'R' `run_analysis.R` script file.
These files were created to meet the course objective of demonstrating the ability to download a data set from the web and 
clean the file, tidy it and export it into another usable data set `tidydata.txt`.

The CodeBook was originally produced as an R markdown file and exported to html as `CodeBook.html` that is also in the repo.

The `run_analysis.R` file downloads the data from the web source specified and then unzips the file, merges the data sets, subsets the data to just have variables that contain mean or std, gives the variables meaningful names, summarises the data by activity and subject using mean and then exports the data to the `tidydata.txt` file.
