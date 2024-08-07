library('ggplot2')
library('dplyr')
library('caTools')
library(class)
library('ROCR')
library(e1071)
library("randomForest")
library('tidyr')
library('RColorBrewer')
library('modelr')
library('caret')
library('pROC')

getwd() # getting working directory

PATH = 'E:/Simplilearn Data Science/1. Data Science with R/R_Projects'

setwd(PATH) # Setting the working directory

options("digits" = 15) # controls the number of digits to print when printing numeric values, currently set to 15

# This is a useful function, which controls the size of the plots created. 
# This function is called before creating almost every plot in this notebook.
# E.g. fig(6,4) --> This will set the width of the plot to 6 units and height as 4 units

fig <- function(width, heigth){
  options(repr.plot.width = width, repr.plot.height = heigth)
}

college_data <- read.csv(paste(PATH,"/Datasets/College_admission.csv", sep = ""), 
                         stringsAsFactors = FALSE)

head(college_data) # checking first 6 observations of data

dim(college_data) # checking the shape of the data, rows and column numbers

# TAsk: Find the missing values. (if any, perform missing value treatment)

any(is.na(college_data)) # checking if there are any missing value in the entire dataset
sapply(college_data, is.null) # checking column wise missing values
college_data %>% summarise_all(~ sum(is.na(.))) # Another way of getting missing value count per column

# Task: Find the structure of the data set and if required, transform the numeric data type to factor and vice-versa.

str(college_data)

college_data_copydf <- data.frame(college_data)

college_data_copydf$Gender_Male <- as.factor(college_data_copydf$Gender_Male)
college_data_copydf$Race <- as.factor(college_data_copydf$Race)
college_data_copydf$admit <- as.factor(college_data_copydf$admit)

college_data_copydf$rank <- factor(college_data_copydf$rank, 
                                   levels=c(4,3,2,1), 
                                   ordered=TRUE)
college_data_copydf$ses <- factor(college_data_copydf$ses, 
                                  levels=c(1,2,3), 
                                  ordered=TRUE)

str(college_data_copydf)
summary(college_data_copydf)

# Task: Find whether the data is normally distributed or not. Use the plot to determine the same. 

# Distribution of GRE Scores - Density Curve

fig(7,4)
college_data_copydf %>% 
  ggplot(aes(x = gre)) +
  geom_density(color="darkblue", fill="lightblue") +
  geom_vline(aes(xintercept=median(gre)),color="blue", linetype="dashed", linewidth=1) +
  ggtitle("Distribution of GRE Scores") +
  xlab("GRE Scores") + ylab("Density") +
  theme_classic() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))


# Distribution 

fig(7,4.5)
college_data_copydf %>%
  ggplot(aes(x = gre)) + 
  geom_histogram(bins = 8, fill = 'dodgerblue') +
  ggtitle("Distribution of GRE Scores") +
  xlab("GRE Scores") + ylab("Frequency") +
  theme_minimal() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))

# Distribution of GPA Points - Density Curve

fig(7,4)
college_data_copydf %>% 
  ggplot(aes(x = gpa)) +
  geom_density(color="darkblue", fill="lightblue") +
  geom_vline(aes(xintercept=median(gpa)),color="blue", linetype="dashed", linewidth=1) +
  ggtitle("Distribution of GPA Points") +
  xlab("GRE Scores") + ylab("Density") +
  theme_classic() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))

fig(7,4.5)
college_data_copydf %>%
  ggplot(aes(x = gpa)) + 
  geom_histogram(bins = 8, fill = 'dodgerblue') +
  ggtitle("Distribution of GPA Points") +
  xlab("GPA Points") + ylab("Frequency") +
  theme_minimal() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))


# Stacked bar plot 

fig(7,4)
college_data_copydf %>%
  ggplot(aes(x=rank, y = gre, fill = Gender_Male)) +
  geom_bar(width = 0.5, stat='identity') +
  labs(fill="Gender") +
  scale_fill_discrete(labels=c('Female', 'Male')) +
  ggtitle("COllege Rank wise GRE Scores (Sum) by Gender") +
  ylab("Total GRE Score Sum") + xlab("Rank of College") +
  theme_minimal() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))

head(college_data)

#

fig(7,4)
college_data_copydf %>%
  ggplot(aes(x=ses, fill = admit)) +
  geom_bar(width = 0.5, stat="count") +
  labs(fill="Admission Status") +
  scale_fill_discrete(labels=c('Not-Admitted', 'Admitted')) +
  ggtitle("Statistic of Admitted Students by Socio-Economic Status") +
  ylab("Count of Students") + xlab("Socio-Economic Status") +
  theme_minimal() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))


#


fig(7,4)
college_data_copydf %>%
  ggplot(aes(x=admit, fill = Gender_Male)) +
  geom_bar(width = 0.4, stat="count") +
  labs(fill="Gender") +
  scale_fill_discrete(labels=c('Female', 'Male')) +
  ggtitle("Statistic of Admitted Students by Gender") +
  ylab("Count of Students") + xlab("Admission Status") +
  theme_minimal() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))


head(college_data_copydf)

socioeconomic_gpa_gre_stats <- college_data_copydf %>%
                              group_by(ses) %>%
                              summarise(gre = median(gre), 
                                        gpa = median(gpa), 
                                        .groups = 'keep')

data.frame(socioeconomic_gpa_gre_stats)


avg_genderwise_scores <- college_data_copydf %>%
                              group_by(Gender_Male) %>%
                              summarise(gre = median(gre), 
                                        gpa = median(gpa), 
                                        .groups = 'keep')

data.frame(avg_genderwise_scores)

# creating new variable 'corr_data' and storing only numeric columns into it 

corr_data = college_data_copydf[,sapply(college_data_copydf, is.numeric)]
head(corr_data)

# creating a correlation matrix, and storing it in a new variable corr_matrix, after rounding it to 2 digits

corr_matrix <- round(cor(corr_data),2)
corr_matrix


# Checking outliers

fig(6,2)
ggplot(college_data_copydf, aes(x = gre)) + 
  stat_boxplot(geom = "errorbar",
               width = 0.15,
               color = 1) +  # Error bar color
  geom_boxplot(fill = 2,           # Box color
               alpha = 0.5,        # Transparency
               color = 1,          # Border color
               outlier.colour = 2) # Outlier color

fig(6,2)
ggplot(college_data_copydf, aes(x = gpa)) + 
  stat_boxplot(geom = "errorbar",
               width = 0.15,
               color = 1) +  # Error bar color
  geom_boxplot(fill = 2,           # Box color
               alpha = 0.5,        # Transparency
               color = 1,          # Border color
               outlier.colour = 2) # Outlier color

#calculate principal components
pca_college_data <- prcomp(college_data[, names(college_data) != "admit"], 
                           center = TRUE,scale = TRUE)

pca_college_data

summary(pca_college_data)

#reverse the signs
pca_college_data$rotation <- -1*pca_college_data$rotation

#display principal components
pca_college_data$rotation


#calculating total variance explained by each principal component

pc_components = 1:6
explained_var_pc = round(pca_college_data$sdev^2 / sum(pca_college_data$sdev^2) *100,2)
cum_explained_var_pc = cumsum(explained_var_pc)
pc_df <- data.frame(pc_components, explained_var_pc, cum_explained_var_pc)

pc_df

fig(7,4)
ggplot(pc_df, aes(x=pc_components, y=explained_var_pc)) +
  geom_line( color="#00AFBB", size = 1, alpha=0.9, linetype=1) +
  geom_point() +
  ggtitle("Scree Plot - Variance explained by each PCs") +
  xlab("Principle Components (PC)") + ylab("Variance Explained") +
  theme_light() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))

fig(7,4)
ggplot(pc_df, aes(x=pc_components, y=cum_explained_var_pc)) +
  geom_line( color="#00AFBB", size = 1, alpha=0.9, linetype=1) +
  geom_point() +
  ggtitle("Scree Plot - Cumulative Variance explained by PCs") +
  xlab("Principle Components (PC)") + ylab("Cumulative Variance Explained") +
  theme_light() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))

# Splitting dataset

set.seed(24)
split <- sample.split(college_data, SplitRatio = 0.8, )
split

train_reg <- subset(college_data, split == "TRUE")
test_reg <- subset(college_data, split == "FALSE")


# Training model
classifier_logistic_model  <- glm(admit ~ ., 
                                  data = train_reg, 
                                  family = "binomial")
classifier_logistic_model

# Summary
summary(classifier_logistic_model)


classifier_logistic_model <- glm(admit ~ gre + gpa + rank, 
                                 data = train_reg, 
                                 family = "binomial")
classifier_logistic_model
summary(classifier_logistic_model)

# Predict test data based on model

predict_reg_train <- predict(classifier_logistic_model, 
                            train_reg, type = "response")

predict_reg_test <- predict(classifier_logistic_model, 
                       test_reg, type = "response")



# Changing probabilities
predict_reg_train <- ifelse(predict_reg_train >0.5, 1, 0)
predict_reg_test <- ifelse(predict_reg_test >0.5, 1, 0)

conf_matrix <- confusionMatrix(table(predicted = predict_reg_test, 
                                     actual = test_reg$admit),
                               positive = "1")

conf_matrix

train_missing_classerr <- mean(predict_reg_train != train_reg$admit)
train_acc = round((1 - train_missing_classerr)*100,2)
print(paste('Train Accuracy = ', train_acc,'%', sep = '' ))

test_missing_classerr <- mean(predict_reg_test != test_reg$admit)
test_acc = round((1 - test_missing_classerr)*100,2)
print(paste('Test Accuracy = ', test_acc,'%', sep = '' ))

Logistic_Model_list <- list('Logistic_Classifier', train_acc, test_acc)

# SVM

scaled_train_reg = scale(train_reg[-c(1)])
scaled_train_reg <- cbind(scaled_train_reg, train_reg[c(1)])

scaled_test_reg = scale(test_reg[-c(1)])
scaled_test_reg <- cbind(scaled_test_reg, test_reg[c(1)])

classifier_svm = svm(formula = admit ~ gre + gpa + rank,
                 data = scaled_train_reg,
                 type = 'C-classification', kernel = 'linear')
summary(classifier_svm)

# Predict test data based on model

predict_reg_train <- predict(classifier_svm, train_reg[c('gre', 'gpa', 'rank')])
predict_reg_test <- predict(classifier_svm, test_reg[c('gre', 'gpa', 'rank')])


# using confusion matrix
table(test_reg$admit, predict_reg_test)

train_missing_classerr <- mean(predict_reg_train != train_reg$admit)
train_acc = round((1 - train_missing_classerr)*100,2)
print(paste('Train Accuracy = ', train_acc,'%', sep = '' ))

test_missing_classerr <- mean(predict_reg_test != test_reg$admit)
test_acc = round((1 - test_missing_classerr)*100,2)
print(paste('Test Accuracy = ', test_acc,'%', sep = '' ))

SVM_Model_list <- list('SVM_Classifier', train_acc, test_acc)
SVM_Model_list

# Random Forest

scaled_train_reg$admit <- as.factor(scaled_train_reg$admit)
scaled_test_reg$admit <- as.factor(scaled_test_reg$admit)

classifier_RF = randomForest(admit ~ ., 
                             data = scaled_train_reg, ntree = 300)

# Predicting the Test set results
y_pred_train = predict(classifier_RF, newdata = scaled_train_reg[-7])
y_pred_test = predict(classifier_RF, newdata = scaled_test_reg[-7])

# Confusion Matrix
conf_matrix <- confusionMatrix(table(predicted = y_pred_test, 
                                     actual = scaled_test_reg$admit),
                               positive = "1")

conf_matrix

# Variable importance plot
varImpPlot(classifier_RF)


train_missing_classerr <- mean(y_pred_train != scaled_train_reg$admit)
train_acc = round((1 - train_missing_classerr)*100,2)
print(paste('Train Accuracy = ', train_acc,'%', sep = '' ))

test_missing_classerr <- mean(y_pred_test != scaled_test_reg$admit)
test_acc = round((1 - test_missing_classerr)*100,2)
print(paste('Test Accuracy = ', test_acc,'%', sep = '' ))


RandomForest_Model_list <- list('RandomForest_Classifier', train_acc, test_acc)
RandomForest_Model_list


# KNN 

classifier_knn <- knn3(formula = admit ~ ., 
                       data = scaled_train_reg,
                       k = 3)
classifier_knn

train_pred = predict(classifier_knn, scaled_train_reg[-c(7)], type = "class")
test_pred = predict(classifier_knn, scaled_test_reg[-c(7)], type = "class")


train_knn_acc <- vector()
test_knn_acc <- vector()

for (n in seq(3,150,2)) {
  classifier_knn <- knn3(formula = admit ~ ., 
                         data = scaled_train_reg,
                         k = n)
  
  train_pred = predict(classifier_knn, scaled_train_reg[-c(7)], type = "class")
  test_pred = predict(classifier_knn, scaled_test_reg[-c(7)], type = "class")

  
  misClassError_train <- mean(train_pred != scaled_train_reg$admit)
  misClassError_test <- mean(test_pred != scaled_test_reg$admit)
  
  train_acc = round((1-misClassError_train)*100,2)
  test_acc = round((1-misClassError_test)*100,2)
  
  train_knn_acc <- append(train_knn_acc, train_acc)
  test_knn_acc <- append(test_knn_acc, test_acc)
  
}

train_knn_acc
test_knn_acc

knn_acc_df <- data.frame(K_value = seq(3,150,2),
                         knn_train_accuracy = train_knn_acc,
                         knn_test_accuracy = test_knn_acc)

#Best K-value 

fig(7,4)
ggplot(knn_acc_df, aes(x=K_value)) +
  geom_line(aes(y = knn_train_accuracy, colour = "knn_train_accuracy")) +
  geom_line(aes(y = knn_test_accuracy, colour = "knn_test_accuracy")) +
  #geom_point() +
  ggtitle("KNN Training and Testing Accuracy Chart") +
  labs(color="Legend text") +
  xlab("K-value") + ylab("Accuracy") +
  theme_light() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))

# Running code with relevant features

train_knn_acc <- vector()
test_knn_acc <- vector()


for (n in seq(3,150,2)) {
  classifier_knn <- knn3(formula = admit ~ gre + gpa + rank, 
                         data = scaled_train_reg,
                         k = n)
  
  train_pred = predict(classifier_knn, scaled_train_reg[-c(7)], type = "class")
  test_pred = predict(classifier_knn, scaled_test_reg[-c(7)], type = "class")
  
  
  misClassError_train <- mean(train_pred != scaled_train_reg$admit)
  misClassError_test <- mean(test_pred != scaled_test_reg$admit)
  
  train_acc = round((1-misClassError_train)*100,2)
  test_acc = round((1-misClassError_test)*100,2)
  
  train_knn_acc <- append(train_knn_acc, train_acc)
  test_knn_acc <- append(test_knn_acc, test_acc)
  
}

train_knn_acc
test_knn_acc

knn_acc_df <- data.frame(K_value = seq(3,150,2),
                         knn_train_accuracy = train_knn_acc,
                         knn_test_accuracy = test_knn_acc)

#Best K-value 

fig(7,4)
ggplot(knn_acc_df, aes(x=K_value)) +
  geom_line(aes(y = knn_train_accuracy, colour = "knn_train_accuracy")) +
  geom_line(aes(y = knn_test_accuracy, colour = "knn_test_accuracy")) +
  #geom_point() +
  ggtitle("KNN Training and Testing Accuracy Chart") +
  labs(color="Legend text") +
  xlab("K-value") + ylab("Accuracy") +
  theme_light() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))


# Zooming 

knn_acc_df_subset <- head(knn_acc_df, 25)


fig(7,4)
ggplot(knn_acc_df_subset, aes(x=K_value)) +
  geom_line(aes(y = knn_train_accuracy, colour = "knn_train_accuracy")) +
  geom_line(aes(y = knn_test_accuracy, colour = "knn_test_accuracy")) +
  #geom_point() +
  ggtitle("KNN Training and Testing Accuracy Chart") +
  labs(color="Legend text") +
  xlab("K-value") + ylab("Accuracy") +
  theme_light() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))

knn_acc_df_subset[knn_acc_df_subset$K_value == 15,]

train_acc <- knn_acc_df_subset[knn_acc_df_subset$K_value == 15,'knn_train_accuracy']
test_acc <- knn_acc_df_subset[knn_acc_df_subset$K_value == 15,'knn_test_accuracy']

KNN_Model_list <- list('KNN_Classifier', train_acc, test_acc)



# Model Comparison 

model_comparison_df = rbind(Logistic_Model_list, SVM_Model_list, RandomForest_Model_list, KNN_Model_list)
colnames(model_comparison_df) <- c("Classifier", 'training_accuracy (in %)', 'test_accuracy (in %)')
rownames(model_comparison_df) <- 1:nrow(model_comparison_df)
model_comparison_df




# Best Model 

classifier_knn <- knn3(formula = admit ~ gre + gpa + rank, 
                       data = scaled_train_reg,
                       k = 15)

train_pred = predict(classifier_knn, scaled_train_reg[-c(7)], type = "class")
test_pred = predict(classifier_knn, scaled_test_reg[-c(7)], type = "class")

misClassError_train <- mean(train_pred != scaled_train_reg$admit)
misClassError_test <- mean(test_pred != scaled_test_reg$admit)

train_acc = round((1-misClassError_train)*100,2)
test_acc = round((1-misClassError_test)*100,2)


conf_matrix <- confusionMatrix(table(predicted = test_pred, 
                                     actual = scaled_test_reg$admit),
                                     positive = "1")
conf_matrix


# ROC Curve

#define object to plot and calculate AUC
rocobj <- roc(scaled_test_reg$admit, factor(test_pred, ordered = TRUE))
auc <- round(auc(scaled_test_reg$admit, factor(test_pred, ordered = TRUE)),4)

ggroc(rocobj, colour = 'steelblue', size = 2) +
  ggtitle(paste0('ROC Curve ', '(AUC = ', auc, ')')) +
  theme_minimal()



# Task: Categorize the average of grade point into High, Medium, and Low (with admission probability percentages) and plot it on a point chart.  

gre_scores <- college_data[, 'gre']

min(gre_scores)
max(gre_scores)

gre_score_categ <- cut(gre_scores, breaks = c(0,440,580,900), labels = c("Low","Medium","High"))
gre_score_categ

college_data$gre_score_category <- gre_score_categ

head(college_data)

table(gre_score_categ)

# Bar plot to show category wise GRE Score count of students

fig(7,4)
college_data %>%
  ggplot(aes(x=gre_score_category)) +
  geom_bar(fill = 'darkblue', stat="count", width = 0.3) + 
  geom_text(aes(label = after_stat(count)), stat = "count", vjust = -0.25, colour = "black") +
  ggtitle("Category wise GRE Scores count") +
  ylab("No. of Students") + xlab("GRE Score Category") +
  theme_minimal() +
  theme(
    plot.title = element_text(color="black", size=14, face="bold.italic", hjust = 0.5),
    axis.title.x = element_text(color="black", size=10, face="bold"),
    axis.title.y = element_text(color="black", size=10, face="bold"))



