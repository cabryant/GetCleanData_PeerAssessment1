# 0. Install/Load required packages

if (!require("dplyr", character.only=TRUE)) {
  install.packages("dplyr")
  if (!require("dplyr", character.only=TRUE)) {
    stop("unable to install and load dplyr!")
  }
}

# 1. Download the data

if (!file.exists("./data")) {
  dir.create("./data")
}
if (!file.exists("./data/wearableComputing.zip")) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                destfile="./data/wearableComputing.zip",
                method="curl")
  unzip("./data/wearableComputing.zip", exdir="./data")
}

# 2. Read in the data

setwd("./data/UCI HAR Dataset")

activity_labels <- read.table("activity_labels.txt")
feature_labels <- read.table("features.txt")

subject_train <- read.table("./train/subject_train.txt")
x_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")

subject_test <- read.table("./test/subject_test.txt")
x_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")

# 3. Appropriately label the data set with descriptive variable names

names(subject_train) <- c("subject")
names(x_train) <- feature_labels$V2
names(y_train) <- c("activity")

names(subject_test) <- c("subject")
names(x_test) <- feature_labels$V2
names(y_test) <- c("activity")

# 4. Merge training and the test sets to create one data set

data_train <- cbind(subject_train, y_train, x_train)
data_test <- cbind(subject_test, y_test, x_test)
data_all <- rbind(data_train, data_test)

# 5. Extract only the measurements on the mean and standard deviation for each measurement.

data_some <- data_all[, grepl("(subject|activity|((mean|std)\\(\\)))", names(data_all))]

# 6. Use descriptive activity names to name the activities in the data set

# Note: we first transform invalid character names to satisfy dplyr.mutate
# Then we convert set back to the original colum names
original_column_names = names(data_some)
valid_column_names <- make.names(names=names(data_some), unique=TRUE)
names(data_some) <- valid_column_names
data_some <- mutate(data_some, activity = activity_labels[activity,2])
names(data_some) <- original_column_names

# 7. Creates a second, independent tidy data set with the
# average of each variable for each activity and each subject

data_tidy <- aggregate(
  data_some[,3:ncol(data_some)],
  list(subject=data_some$subject, activity=data_some$activity), 
  mean)

setwd(../..)
write.table(data_tidy, "./tidy_summary.txt", row.names=FALSE)
