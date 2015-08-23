library(reshape2)

file.name <- "getdata_dataset.zip"
data.dir <- "UCI HAR Dataset"

## Download and unzip the dataset:
if (!file.exists(data.dir)) {
    file.URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "

    download.file(file.URL, file.name, method="curl")
}  

unzip(file.name) 

# Work in the data dir to load data. Then hop back to parent dir when saving the results.
# Note the assumption that the file will unzip into a directory called "UCI HAR Dataset"
setwd(data.dir)

# Get the labels and features - set the data as character strings
activity.labels <- read.table("activity_labels.txt")
activity.labels[,2] <- as.character(activity.labels[,2])
features <- read.table("features.txt")
features[,2] <- as.character(features[,2])

# features.included is all the features which represent Means or StdDeviations.
features.included <- grep(".*mean.*|.*std.*", features[,2])
features.included.names <- features[features.included,2]
features.included.names = gsub('-mean', 'Mean', features.included.names)
features.included.names = gsub('-std', 'Std', features.included.names)
features.included.names <- gsub('[-()]', '', features.included.names)


# Load the datasets
train <- read.table("train/X_train.txt")[features.included]
activities.training <- read.table("train/Y_train.txt")
subjects.training <- read.table("train/subject_train.txt")
train <- cbind(subjects.training, activities.training, train)

test <- read.table("test/X_test.txt")[features.included]
activities.test <- read.table("test/Y_test.txt")
subjects.test <- read.table("test/subject_test.txt")
test <- cbind(subjects.test, activities.test, test)

# Back up to parent directory.
setwd("..")

# merge datasets 
all.data <- rbind(train, test)

# Friendly names for the columns
colnames(all.data) <- c("subject", "activity", features.included.names)

# Set the activities and the subjects to be factors.
all.data$activity <- factor(all.data$activity, levels = activity.labels[,1], labels = activity.labels[,2])
all.data$subject <- as.factor(all.data$subject)

all.data.melted <- melt(all.data, id = c("subject", "activity"))
all.data.mean <- dcast(all.data.melted, subject + activity ~ variable, mean)

write.table(all.data.mean, "summary.txt", row.names = FALSE, quote = FALSE)
