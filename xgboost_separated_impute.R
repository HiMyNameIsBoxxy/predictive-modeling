# Load required libraries
library(dplyr)
library(caret)
library(xgboost)
library(MASS)

# Load data
train <- read.csv("analysis_data.csv")
test <- read.csv("scoring_data.csv")

str(train)

# --- Apply Box-Cox Transformation to CTR ---
# Box-Cox requires positive values, so we add a small constant (1)
train$CTR <- train$CTR + 1

# Find the optimal lambda for the Box-Cox transformation
lambda <- boxcox(lm(CTR ~ 1, data = train), lambda = seq(-2, 2, 0.1))$x[which.max(boxcox(lm(CTR ~ 1, data = train), lambda = seq(-2, 2, 0.1))$y)]
print(paste("Optimal lambda:", lambda))

# Apply Box-Cox transformation using the optimal lambda
if (lambda == 0) {
  train$CTR <- log(train$CTR)
} else {
  train$CTR <- (train$CTR ^ lambda - 1) / lambda
}

# --- Separate Columns by Data Type ---
train_numeric_cols <- train %>% select_if(~ is.numeric(.) || is.integer(.)) %>% colnames()
train_categorical_cols <- train %>% select_if(is.character) %>% colnames()

test_numeric_cols <- test %>% select_if(~ is.numeric(.) || is.integer(.)) %>% colnames()
test_categorical_cols <- test %>% select_if(is.character) %>% colnames()

# --- Impute Numeric Columns ---
set.seed(1031)
# Fit the numeric imputer on the training data
train_numeric_imputer <- preProcess(train[, train_numeric_cols], method = 'bagImpute')
test_numeric_imputer <- preProcess(test[, test_numeric_cols], method = 'bagImpute')

# Impute numeric columns in both train and test datasets
train_numeric_imputed <- predict(train_numeric_imputer, newdata = train[, train_numeric_cols])
test_numeric_imputed <- predict(test_numeric_imputer, newdata = test[, test_numeric_cols])

# --- Impute Categorical Columns ---
impute_mode <- function(x) {
  # Get the mode (most common value) for each column
  mode_value <- names(sort(table(x), decreasing = TRUE))[1]
  x[is.na(x)] <- mode_value
  return(x)
}

# Apply mode imputation for categorical columns in both datasets
train_categorical_imputed <- train[, train_categorical_cols] %>% mutate_all(impute_mode)
test_categorical_imputed <- test[, test_categorical_cols] %>% mutate_all(impute_mode)

# --- Combine Imputed Numeric and Categorical Data ---
train_final <- cbind(train_numeric_imputed, train_categorical_imputed)
test_final <- cbind(test_numeric_imputed, test_categorical_imputed)

# Check the final datasets
str(train_final)
str(test_final)
colSums(is.na(test_final))

# List of columns to remove based on feature importance analysis (adjusted to original dataset)
columns_to_remove <- c("seasonality", "market_saturation", "headline_question")

# Use dplyr::select() to avoid namespace conflict
train_final <- dplyr::select(train_final, -all_of(intersect(columns_to_remove, colnames(train_final))))
test_final <- dplyr::select(test_final, -all_of(intersect(columns_to_remove, colnames(test_final))))

# Check the final datasets
str(train_final)
str(test_final)
colSums(is.na(test_final))

# --- MODEL TRAINING WITH LOG TRANSFORMATION ---

# --- Identify Numeric and Categorical Columns ---
train_numeric_cols <- train_final %>% select_if(is.numeric) %>% colnames()
train_categorical_cols <- train_final %>% select_if(is.character) %>% colnames()

# --- Label Encode Categorical Columns ---

# Function to label encode categorical columns
label_encode <- function(df, cols) {
  for (col in cols) {
    df[[col]] <- as.integer(as.factor(df[[col]]))
  }
  return(df)
}

# Apply label encoding to train and test datasets
train_final <- label_encode(train_final, train_categorical_cols)
test_final <- label_encode(test_final, test_categorical_cols)

# --- Convert to Matrix Format for XGBoost ---
# Separate predictors and target variable
train_x <- dplyr::select(train_final, -CTR)
train_y <- train_final$CTR
test_x <- test_final


# Convert data to matrix format for XGBoost
train_matrix <- as.matrix(train_x)
test_matrix <- as.matrix(test_x)

# Check the structure of the matrix
str(train_matrix)

# Define an extended tuning grid for XGBoost to explore more hyperparameters
tune_grid <- expand.grid(
  nrounds = c(100, 200, 300),
  max_depth = c(3, 4, 5, 6),
  eta = c(0.01, 0.05, 0.1, 0.2),
  gamma = c(0, 0.01, 0.1),
  colsample_bytree = c(0.5, 0.7, 0.9),
  subsample = c(0.6, 0.8, 1.0),
  min_child_weight = c(1, 3, 5)
)

# Set up cross-validation controls
train_control <- trainControl(method = "cv", number = 5, verboseIter = TRUE)
train_final <- dplyr::select(train_final, -all_of(intersect(columns_to_remove, colnames(train_final))))
test_final <- dplyr::select(test_final, -all_of(intersect(columns_to_remove, colnames(test_final))))

# Tune the XGBoost model to find the best parameters
set.seed(123)
xgb_tuned <- train(
  x = train_matrix,
  y = train_y,
  method = "xgbTree",
  trControl = train_control,
  tuneGrid = tune_grid,
  metric = "RMSE"
)

# Print the best tuning parameters
print(xgb_tuned$bestTune)

# Define final model parameters based on best tuning results
params <- list(
  objective = "reg:squarederror",
  eval_metric = "rmse",
  nthread = 2,
  max_depth = xgb_tuned$bestTune$max_depth,
  eta = xgb_tuned$bestTune$eta,
  subsample = xgb_tuned$bestTune$subsample,
  colsample_bytree = xgb_tuned$bestTune$colsample_bytree,
  gamma = xgb_tuned$bestTune$gamma,
  min_child_weight = xgb_tuned$bestTune$min_child_weight
)

# Convert training data to DMatrix format
train_dmatrix <- xgb.DMatrix(data = train_matrix, label = train_y)

# Train the final XGBoost model with the best parameters
xgb_model <- xgboost(
  params = params,
  data = train_dmatrix,
  nrounds = xgb_tuned$bestTune$nrounds,
  verbose = 1
)


# For the scoring data, convert to DMatrix and make predictions
scoring_matrix <- as.matrix(test_final)
scoring_dmatrix <- xgb.DMatrix(data = scoring_matrix)
scoring_pred <- predict(xgb_model, scoring_dmatrix)

# Make predictions on the test set
test_dmatrix <- xgb.DMatrix(data = test_matrix)
scoring_dmatrix <- xgb.DMatrix(data = scoring_matrix)

# --- Inverse Box-Cox Transformation ---
if (lambda == 0) {
  scoring_pred <- exp(scoring_pred)
} else {
  scoring_pred <- (scoring_pred * lambda + 1)^(1 / lambda) - 1
}


# Create submission file
submission <- data.frame(id = test$id, CTR = scoring_pred)
write.csv(submission, "xgboost_grid_skewed_separated.csv", row.names = FALSE)

# --- Model Evaluation ---
residuals <- xgb_tuned$resample$RMSE
mean_rmse <- mean(residuals)
print(paste("Cross-Validated RMSE:", round(mean_rmse, 4)))