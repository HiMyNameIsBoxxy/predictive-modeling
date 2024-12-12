# Load required libraries
library(dplyr)
library(caret)
library(xgboost)

# Load data
train <- read.csv("analysis_data.csv")
test <- read.csv("scoring_data.csv")

# Impute missing values in numeric columns (baseline imputation without engineered features)
analysis_numeric <- train %>% select_if(is.numeric)
set.seed(1031)
analysis_numeric_imputed <- predict(preProcess(analysis_numeric, method = 'bagImpute'), newdata = analysis_numeric)
train_final <- analysis_numeric_imputed

# Impute missing values for test (scoring) data
scoring_numeric <- test %>% select_if(is.numeric)
set.seed(1031)
scoring_numeric_imputed <- predict(preProcess(scoring_numeric, method = 'bagImpute'), newdata = scoring_numeric)
test_final <- scoring_numeric_imputed

# --- Remove low-importance features ---

# List of columns to remove based on feature importance analysis (adjusted to original dataset)
columns_to_remove <- c("headline_power_words", "headline_numbers", "headline_question", "age_group", "location", "market_saturation", "gender", "brand_familiarity", "position_on_page")

# Use dplyr::select() to avoid namespace conflict
train_final <- dplyr::select(train_final, -all_of(intersect(columns_to_remove, colnames(train_final))))
test_final <- dplyr::select(test_final, -all_of(intersect(columns_to_remove, colnames(test_final))))

# Check the final datasets
str(train_final)
str(test_final)
colSums(is.na(test_final))

# --- MODEL TRAINING ---

# Separate predictors and target variable
train_x <- train_final %>% dplyr::select(-CTR)
train_y <- train_final$CTR
test_x <- test_final

# Convert data to matrix format for XGBoost
train_matrix <- as.matrix(train_x)
test_matrix <- as.matrix(test_x)

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

# Make predictions on the test set
test_pred <- predict(xgb_model, test_dmatrix, iteration_range = c(0, xgb_tuned$bestTune$nrounds))
scoring_pred <- predict(xgb_model, scoring_dmatrix, iteration_range = c(0, xgb_tuned$bestTune$nrounds))

# For the scoring data, convert to DMatrix and make predictions
scoring_matrix <- as.matrix(test_final)
scoring_dmatrix <- xgb.DMatrix(data = scoring_matrix)
scoring_pred <- predict(xgb_model, scoring_dmatrix)

# Create submission file
submission <- data.frame(id = test$id, CTR = scoring_pred)
write.csv(submission, "xgboost_grid_selection_submission.csv", row.names = FALSE)

# --- Model Evaluation ---
# Extract feature importance
importance_matrix <- xgb.importance(model = xgb_model)

# View the importance of each feature
print(importance_matrix)

residuals <- xgb_tuned$resample$RMSE
mean_rmse <- mean(residuals)
print(paste("Cross-Validated RMSE:", round(mean_rmse, 4)))


# Save the trained model
saveRDS(xgb_model, file = "xgb_model.rds")

# Save the tuning results
saveRDS(xgb_tuned, file = "xgb_tuned_results.rds")

# Load the trained model
xgb_model <- readRDS("xgb_model.rds")

# Load the tuning results
xgb_tuned <- readRDS("xgb_tuned_results.rds")
