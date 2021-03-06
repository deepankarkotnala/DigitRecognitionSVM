##===========================================================================##
##   Project     : Handwritten Digit Recognition                             ##
##                                                                           ##
##   Description : We have a few images of handwritten digits submitted by   ##
##                 a user via a scanner, a tablet, or other digital devices. ##
##                 Our objective is to develop a model using Support Vector  ##
##                 Machine which should correctly classify the handwritten   ##
##                 digits based on the pixel values given as features.       ##
##                                                                           ##
##   Date        : 23-Dec-2018                                               ##
##                                                                           ##
##   Author      : Deepankar Kotnala                                         ##
##===========================================================================##

setwd("D:/iiitB/R/Predictive Analytics 2/assignment digit recognition")

##===========================================================================##
##                                                                           ##
##                        Business Understanding                             ##
##                                                                           ##
##===========================================================================##

## We have a few images of digits submitted by a user via a scanner, a tablet, or other digital devices. 
## Our objective is to develop a model using Support Vector Machine which should correctly classify the 
## handwritten digits based on the pixel values given as features.

##===========================================================================##
# Removing all the objects from the workspace
remove(list = ls())
# Suppressing the warnings
options(warn=-1)

##===========================================================================##
options(warn=-1)    # Suppressing the warnings
pkgs <- c("fansi","readr","caTools","kernlab","caret","beepr","e1071")

install_libraries <- pkgs[!pkgs %in% installed.packages()] # get the package list which are not installed 
for (i in install_libraries)
  install.packages(i, dependencies = T)
loadlib <- lapply(pkgs, require, character.only = TRUE) # Load the required libraries

remove(list = ls()) # Remove unnecessary objects - Cleaning the environment

#library("fansi")
#library("readr")            ## required for read_csv
#library("caTools")          ## required for sample.split
#library("kernlab")          ## required for ksvm model
#library("caret")            ## required for confusionMatrix
#library("beepr")            ## beep() function to give a beep sound after a process gets completed.

##===========================================================================##
# Load the Data
# This is the MNIST Dataset.
train <- read_csv("mnist_train.csv")
test  <- read_csv("mnist_test.csv")

# Changing the column names
colnames(train) <- c("digit", paste0("p", 1:784))
colnames(test)  <- c("digit", paste0("p", 1:784))

##===========================================================================##
##                                                                           ##
##                       Data Understanding and EDA                          ##
##                                                                           ##
##===========================================================================##
# The MNIST database (Modified National Institute of Standards and Technology database) 
# is a large database of handwritten digits that is commonly used for training various 
# image processing systems.

# Understanding Dimensions
dim(train) # 59999  785
dim(test)  #  9999  785

# Since the dataset is huge, we are advised to take a sample of 15% data for our model. 
set.seed(1)
indices_train = sample.split(train$digit, SplitRatio = 0.15)
        train = train[indices_train,]

# New Dimensions
dim(train) # 9000  785
dim(test)  # 9999  785

# Structure of the dataset
str(train)
str(test)

# Printing first few rows
head(train)
head(test)

# Exploring the data. Here we are looking at 10 rows and 10 columns of the train and test datasets.
train[1:10, 1:10]
test [1:10, 1:10]

# Changing the target class (digit column) to factor in train and test datasets.
train$digit <- as.factor(train$digit)
test$digit  <- as.factor(test$digit)

# Checking for NA values
length(which(is.na(train)))
length(which(is.na(test)))
# No NA values present in train and test dataset.

# Geting a summmary of the different categories of digits and count of data present for each.
table(train$digit)
table(test$digit)

# Checking if there is any column with non-numeric value.
which(sapply(train, is.numeric)==FALSE)
# Only the first column, i.e, digit is not a number. 
# digit is a factor, since we are not considering the quantity here, but the classification.
# Rest all 784 variables are numeric.

# Checking for duplicates in train and test dataset.
sum(duplicated(rbind(train, test)))
# No duplicates found in train and test datasets.

# Data is clean and standardised. Hence there is no need for feature standardisation (scaling).

##===========================================================================##
##                                                                           ##
##                              Model Building                               ##
##                                                                           ##
##===========================================================================##

#Using Linear Kernel
(Model_linear <- ksvm(digit~., data=train, scale = FALSE, kernel = "vanilladot"))
# SV type: C-svc  (classification) 
# parameter : cost C = 1 
# Linear (vanilla) kernel function. 
# Number of Support Vectors : 2603
# Predicting the digits using Linear Model

Evaluate_linear <- predict(Model_linear, test)

# Confusion matrix - Finding the accuracy, sensitivity and specificity
confusionMatrix(Evaluate_linear, test$digit)

# Accuracy : 0.9113 (91.13%)

#                   Class: 0 Class: 1 Class: 2 Class: 3 Class: 4 Class: 5 Class: 6 Class: 7 Class: 8 Class: 9
# Sensitivity        0.98163   0.9824  0.90213  0.91089  0.92668  0.85202  0.92902  0.90750  0.83881  0.86720
# Specificity        0.99246   0.9942  0.98818  0.98376  0.98736  0.99067  0.99215  0.99119  0.99269  0.98877
# Balanced Accuracy  0.98705   0.9883  0.94516  0.94732  0.95702  0.92134  0.96058  0.94935  0.91575  0.92798
##===========================================================================##

#Using RBF Kernel
(Model_RBF    <- ksvm(digit~., data = train, scale = FALSE, kernel = "rbfdot"))
# SV type: C-svc  (classification) 
# parameter : cost C = 1 
# Gaussian Radial Basis kernel function. 
# Hyperparameter : sigma =  1.63910776656003e-07 
# We will use this value of sigma in Cross Validation.
# Number of Support Vectors : 3595 
# Training error : 0.019444 

# Predicting the digits using RBF Model
Evaluate_RBF <- predict(Model_RBF, test)

# Confusion Matrix - RBF Kernel
confusionMatrix(Evaluate_RBF,test$digit)
##===========================================================================##
# Accuracy : 0.9566 (95.66%)
#                   Class: 0 Class: 1 Class: 2 Class: 3 Class: 4 Class: 5 Class: 6 Class: 7 Class: 8 Class: 9
# Sensitivity        0.98980   0.9921  0.94574  0.95743  0.96029  0.94507  0.97077  0.94352  0.93121  0.92567
# Specificity        0.99612   0.9972  0.99587  0.99388  0.99368  0.99495  0.99569  0.99565  0.99535  0.99344
# Balanced Accuracy  0.99296   0.9946  0.97081  0.97565  0.97698  0.97001  0.98323  0.96959  0.96328  0.95955
##===========================================================================##

##===========================================================================##
##                                                                           ##
##             Hyperparameter tuning and Cross Validation                    ##
##                                                                           ##
##===========================================================================##

# We will use the train function from caret package to perform Cross Validation. 

# "traincontrol" function controls the computational nuances of the train function.
# Different parameters are explained below:
# method =  CV means  Cross Validation.
# number = 3 implies  Number of folds in CV.
# verboseIter = TRUE  Gives us the current status of training process.

trainControl <- trainControl(method="cv", number=5, verboseIter = TRUE)

# Metric <- "Accuracy" implies that our Evaluation metric is Accuracy.
metric <- "Accuracy"

set.seed(1)
# Printing the Linear Model "Model_RBF" attributes -  for getting the suitable value of sigma.
Model_RBF
# sigma = 1.63910776656003e-07
# Let's try to put values nearby the above value of sigma in the below command.
# We will take the rounded off value of sigma. i.e, sigma = 1.64e-07 (approx.)
# After a few hit and trials, the 5 values of sigma are selected as below for considering in tuneGrid:
# (sigma -1), (sigma), (sigma + 1), (sigma +2), (sigma +3)
# Expand.grid functions takes set of hyperparameters, that we shall pass to our model.
grid <- expand.grid(.sigma=c(0.64e-07, 1.64e-07, 2.64e-07, 3.64e-07, 4.64e-07), .C=c(1,2,3,4,5))

# train function takes Target ~ Prediction, 
# Data   => The dataset used (train dataset here), 
# Method => Algorithm (svmRadial)
# Metric => Type of metric, tuneGrid = Grid of Parameters,
# trcontrol => Our traincontrol method.

svm_cross_val <- train(digit~., data = train, method = "svmRadial", metric = metric, 
                       tuneGrid = grid, trControl = trainControl)

# Used the beepr package and beep function to generate a beep sound notification after 
# the completion of above command.
beep() 

# Printing cross validation result
print(svm_cross_val)

# Having a look at the best tuned parameters
svm_cross_val$bestTune
# Best tune at sigma (Fitting sigma) = 3.64e-07 & C= 5
# Accuracy = 96.56% at the above sigma and cost values.

# Plotting model results
plot(svm_cross_val)

##===========================================================================##
##                          Final Model Building                             ##
##===========================================================================##

# Source: https://www.rdocumentation.org/packages/kernlab/versions/0.3-1/topics/ksvm

# Putting the best tune values of sigma and cost and building our final model.

final_RBF_model <- ksvm(digit~., data = train, scale = FALSE,C = 5, 
                        kpar = list(sigma = 3.64e-7), kernel = "rbfdot")

# Parameters used in the above command:  
# kpar   : The list of hyper-parameters (kernel parameters). This is a list which contains the parameters 
#          to be used with the kernel function. For valid parameters for existing kernels are :
#          --  sigma: inverse kernel width for the Radial B
# C      : cost of constraints violation (default: 1)---it is the `C'-constant of the regularization term 
#          in the Lagrange formulation.
# scale  : A logical vector indicating the variables to be scaled.
# kernel : the kernel function used in training and predicting.

##===========================================================================##
##                        Final Model Evaluation                             ##
##===========================================================================##

# Checking overfitting - Non-Linear - SVM

# Validating the model results on test data
Evaluate_RBF_test  <- predict(final_RBF_model, test)
(conf_matrix_test   <- confusionMatrix(Evaluate_RBF_test , test$digit))

# Accuracy = 96.96%
#                  Class: 0 Class: 1 Class: 2 Class: 3 Class: 4 Class: 5 Class: 6 Class: 7 Class: 8 Class: 9
#Sensitivity        0.99184   0.9894  0.96027  0.97129  0.97658  0.96861  0.97704  0.95424  0.95791  0.94747
#Specificity        0.99701   0.9981  0.99610  0.99588  0.99645  0.99758  0.99801  0.99576  0.99546  0.99588
#Balanced Accuracy  0.99442   0.9938  0.97818  0.98359  0.98651  0.98310  0.98752  0.97500  0.97668  0.97168

colMeans(conf_matrix_test$byClass)
#    Sensitivity          Specificity     Pos Pred Value Neg Pred Value 
#      0.9694660            0.9966220          0.9694929      0.9966239 
#      Precision               Recall                 F1     Prevalence 
#      0.9694929            0.9694660          0.9694561      0.1000000 
# Detection Rate Detection Prevalence  Balanced Accuracy 
#      0.0969597            0.1000000          0.9830440 

# The Accuracy, Sensitivity, and Specificity of the model predictions on the test data are as follows:

# Accuracy    - 0.9830 (98.30 %)
# Sensitivity - 0.9694 (96.94 %)
# Specificity - 0.9966 (99.66 %)

##===========================================================================##
##                               S U M M A R Y                               ##
##===========================================================================##

# The approximate accuracies of both the models are:
# Linear kernel accuracy : 91.13 %
# RBF kernel accuracy    : 95.66 %

# The final model is a non-linear RBF_model.
# Cross-validation is performed on this.

# Optimum values of sigma and cost for best tuning are:
# Sigma = 3.64e-07 & Cost = 5

# On Validating the final model results on test data, we get:
#  Accuracy    - 0.9830 (98.30 %)
#  Sensitivity - 0.9694 (96.94 %)
#  Specificity - 0.9966 (99.66 %)

##===========================================================================##
##                          E N D   O F   F I L E                            ##
##===========================================================================##

