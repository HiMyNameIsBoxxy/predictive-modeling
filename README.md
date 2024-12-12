---
title: "PAC Competition"
author: "Huan Shuo Hsu"
format: 
  html:
    toc: true
    toc-location: left
    toc-depth: 4
editor: visual
---

# Load Data

The provided dataset `analsysis_data` will be the train set, and `scoring_data` will be the test set.

```{r}
#| message: false
#| warning: false
# --- Load Required Libraries ---
library(dplyr)
library(caret)

# --- Load Data ---
train <- read.csv("analysis_data.csv")
test <- read.csv("scoring_data.csv")
```

# Data Exploration

To begin the analysis, the `skim` function is used from the **skimr** package to gain an overview of the dataset. This function provides a summary of each variable, including its distribution, data type, and completeness. We will then pick out a few important variables base on domain knowledge and take a deeper dive into their structure.

```{r}
library(skimr)
skim(train)
```

#### Key Summary

-   `4000` observations
-   `29` variables
-   `8` `character` type variables
-   `12` `numeric` type variables
-   The `complete_rate` of the data are all above `94%`.
-   **Skewness and Distribution**
    -   Several variables appear heavily skewed, as seen in the distribution charts `(▇▃▁▁▁, ▇▁▁▁▇)`.
    -   For instance, variables like `CTR`, `visual_appeal`, and `market_saturation` are **right-skewed** (long tails toward higher values).
-   **Range of Values**
    -   Wide Ranges: Some variables have a large range of values, indicating potential outliers or diverse scales:
        -   `visual_appeal`: Min = `-9.54`, Max = `26.45`.
        -   `CTR`: Min = `0.00`, Max = `3.75`.
    -   Binary/Categorical Variables: Variables like `headline_question`, `headline_numbers`, and `contextual_relevance` appear binary, with values predominantly `0` or `1`.

### CTR (Click Through Rate)

-   Mean = `0.22`, Median = `0.18`: Right-skewed distribution confirmed by the histogram `(▇▁▁▁▁).`
-   The range (`0.00` to `3.75`) indicates most observations are clustered at lower values, with few extreme values.
-   Suggests potential outliers in CTR that need handling. This **high skewness** confirms that the CTR variable is not normally distributed and may require transformations or a model capable of handling skewed data, such as decision-tree-based methods like XGBoost.

```{r}
#| message: false
#| warning: false
# Load necessary libraries
library(ggplot2)
library(e1071)

# Extract the CTR variable
ctr_data <- train$CTR

# Calculate skewness
ctr_skewness <- skewness(ctr_data)

# Plot the distribution of CTR
ggplot(data.frame(CTR = ctr_data), aes(x = CTR)) +
  geom_histogram(bins = 30, fill = "blue", alpha = 0.7, color = "black") +
  geom_density(aes(y = ..count..), color = "red", size = 1) +
  labs(
    title = paste("Distribution of CTR (Skewness =", round(ctr_skewness, 2), ")"),
    x = "CTR",
    y = "Frequency"
  ) +
  theme_minimal()

# Display summary statistics
ctr_summary <- summary(ctr_data)
ctr_skewness
ctr_summary
```

### Targeting Score

-   Mean = `4.02`, Median = `3.00`: The variable is **moderately skewed right**, as most values are clustered toward the lower end.
-   Maximum = `23`, which might be an outlier considering the interquartile range (IQR = `3.00` to `5.00`).

```{r}
#| message: false
#| warning: false
# Histogram for Targeting Score
ggplot(data.frame(TargetingScore = train$targeting_score), aes(x = TargetingScore)) +
  geom_histogram(binwidth = 1, fill = "purple", alpha = 0.7, color = "black") +
  labs(title = "Distribution of Targeting Score", x = "Targeting Score", y = "Frequency") +
  theme_minimal()
```

### Visual Appeal

-   **Large range**: Min = `-9.54`, Max = `26.45`. Negative values suggest data issues or a specific encoding for certain conditions.

```{r}
#| message: false
#| warning: false
# Histogram for Visual Appeal
ggplot(data.frame(VisualAppeal = train$visual_appeal), aes(x = VisualAppeal)) +
  geom_histogram(binwidth = 1, fill = "red", alpha = 0.7, color = "black") +
  labs(title = "Distribution of Visual Appeal", x = "Visual Appeal", y = "Frequency") +
  theme_minimal()
```

### Contextual Relevance

-   Binary variable: Almost entirely `0s` and `1s`. The histogram shows two spikes at these values `(▇▁▁▁▇).`

```{r}
#| message: false
#| warning: false
# Barplot for Contextual Relevance (binary variable)
ggplot(data.frame(ContextualRelevance = factor(train$contextual_relevance)), aes(x = ContextualRelevance)) +
  geom_bar(fill = "darkblue", alpha = 0.7) +
  labs(title = "Barplot of Contextual Relevance", x = "Contextual Relevance (0 or 1)", y = "Count") +
  theme_minimal()
```

### Headline Sentiment

-   Mean = `-0.03`, Median = `-0.07`: Near-zero mean suggests a **balanced sentiment** overall.
-   Distribution is fairly normal `(▁▃▇▃▁)`, but the range (`-7.04 to`7.11\`) shows some **extreme sentiment values**.

```{r}
#| message: false
#| warning: false
# Histogram for Headline Sentiment
ggplot(data.frame(HeadlineSentiment = train$headline_sentiment), aes(x = HeadlineSentiment)) +
  geom_histogram(binwidth = 0.5, fill = "magenta", alpha = 0.7, color = "black") +
  labs(title = "Distribution of Headline Sentiment", x = "Headline Sentiment", y = "Frequency") +
  theme_minimal()
```

### Body Keyword Density

-   Mean = `0.06`, Median = `0.05`: Relatively low density, with a narrow range (`0.01` to `0.10`).
-   Appears **evenly distributed** (`▇▇▇▇▇`).

```{r}
#| message: false
#| warning: false
# Histogram for Body Keyword Density
ggplot(data.frame(BodyKeywordDensity = train$body_keyword_density), aes(x = BodyKeywordDensity)) +
  geom_histogram(binwidth = 0.01, fill = "orange", alpha = 0.7, color = "black") +
  labs(title = "Distribution of Body Keyword Density", x = "Body Keyword Density", y = "Frequency") +
  theme_minimal()
```

### Body Readability Score

-   Mean = `74.87`, Median = `74.76`: Centered around the same value, suggesting a narrow range of readability scores.
-   Minimum = `50.04`, Maximum = `100`: High values indicate content is generally readable.

```{r}
#| message: false
#| warning: false
# Histogram for Body Readability Score
ggplot(data.frame(BodyReadability = train$body_readability_score), aes(x = BodyReadability)) +
  geom_histogram(binwidth = 5, fill = "green", alpha = 0.7, color = "black") +
  labs(title = "Distribution of Body Readability Score", x = "Body Readability Score", y = "Frequency") +
  theme_minimal()
```

# Data Cleaining

The data cleaning process began with examining the structure and content of the training and testing datasets. To **address skewness** in the target variable CTR, a **Box-Cox transformation** was applied after adding a small constant to ensure all values were positive, and the optimal lambda was determined to improve normality. Missing values were handled separately for numeric and categorical variables: numeric columns were imputed using the **bagging method** from the caret package, while categorical columns were imputed with the most frequent value (`mode`). After imputation, numeric and categorical columns were recombined into complete datasets with no missing values. Non-contributory columns, identified through 88feature importance analysis88 (`seasonality`, `market_saturation`, `headline_question`), were removed to reduce noise. These steps ensured the data was clean, consistent, and ready for modeling.

### Handling Skewness of CTR

-   The target variable `CTR` (Click-Through Rate) is adjusted for skewness to improve model performance.
-   **Box-Cox Transformation**: Applied to `CTR` since it requires positive values. A small constant (+1) is added to all values. The optimal Box-Cox lambda is determined using the boxcox function from the MASS package.
-   Transformation ensures the target variable is more normally distributed, which benefits models sensitive to non-normality.

```{r}
#| message: false
#| warning: false
# Load necessary libraries
library(MASS)

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
```

### Separating Columns by Data Type

-   Columns are categorized into **numeric** and **categorical** variables for targeted processing.
-   Numeric Columns: Includes continuous and integer variables.
-   Categorical Columns: Includes string or factor variables.

```{r}
#| message: false
#| warning: false
train_numeric_cols <- train %>% select_if(~ is.numeric(.) || is.integer(.)) %>% colnames()
train_categorical_cols <- train %>% select_if(is.character) %>% colnames()

test_numeric_cols <- test %>% select_if(~ is.numeric(.) || is.integer(.)) %>% colnames()
test_categorical_cols <- test %>% select_if(is.character) %>% colnames()
```

### Imputing Missing Values

-   To handle missing data, different strategies are used for numeric and categorical variables
-   Numeric Columns:
    -   **Bagging Imputation**:
        -   Missing numeric values are imputed using the caret package's bagImpute method.
        -   This method uses bootstrap aggregating (bagging) to make predictions based on other numeric columns, ensuring robust imputation.
-   Categorical Columns:
    -   **Mode Imputation**:

        -   The most frequent value (`mode`) is used to fill missing values in each categorical column.
        -   A custom `impute_mode` function ensures consistent handling of missing values.

        ```{r}
        #| message: false
        #| warning: false
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

        # Make sure all missing values are filled
        colSums(is.na(train_final))
        ```

        All missing values from `train` and `test` are now filled. The dataset is ready for training.

### Feature Selection

The features (`headline_power_words`, `headline_numbers`, `headline_question`, `age_group`, `location`, `market_saturation`, `gender`, `brand_familiarity`, `position_on_page`) were removed based on a combination of feature importance analysis from xgboosting and domain knowledge. The **xgboosting** method used will be displayed after this section. These columns were found to have low predictive value or redundant information, contributing minimally to the model's performance. Including such features can introduce noise, lead to overfitting, and unnecessarily increase model complexity. Removing them improves the model's interpretability, reduces computational cost, and enhances generalizability to new data.

```{r}
#| message: false
#| warning: false
# --- Feature Importance ---

# List of columns to remove based on previous analysis
columns_to_remove <- c("headline_power_words", "headline_numbers", "headline_question", "age_group", "location", "market_saturation", "gender", "brand_familiarity", "position_on_page")

# Remove specified columns from the dataset
train_final <- dplyr::select(train_final, -all_of(intersect(columns_to_remove, colnames(train_final))))
test_final <- dplyr::select(test_final, -all_of(intersect(columns_to_remove, colnames(test_final))))

```

# XGBoost

-   Separated Predictors and Target: Extracted the predictor features (`train_x`) and the target variable (`train_y`) from the training dataset. Assigned the test dataset predictors to `test_x`.
-   Converted Data to **Matrix Format**: Prepared the data in matrix format as required by XGBoost.

```{r}
#| eval: false
# --- Label Encode Categorical Columns ---
# Identify Numeric and Categorical Columns
train_numeric_cols <- train_final %>% select_if(is.numeric) %>% colnames()
train_categorical_cols <- train_final %>% select_if(is.character) %>% colnames()

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

# --- MODEL TRAINING ---
# Separate predictors and target variable
train_x <- train_final %>% dplyr::select(-CTR)
train_y <- train_final$CTR
test_x <- test_final

# Convert data to matrix format for XGBoost
train_matrix <- as.matrix(train_x)
test_matrix <- as.matrix(test_x)
```

### Cross Validation

Configured a *5-fold cross-validation* process with verbose output to monitor progress during training. This is to evaluate model performance across multiple folds of the training data, ensuring that the model generalizes well and avoids overfitting.

```{r}
#| eval: false
# Set up cross-validation controls
train_control <- trainControl(method = "cv", number = 5, verboseIter = TRUE)
```

### Hyperparameter Tuning

Created a tuning grid to explore a range of hyperparameter values for the XGBoost model to systematically explore combinations of hyperparameters to optimize model performance.

```{r}
#| eval: false
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
```

# Prediction

The final prediction resulted in **RMSE** of `0.081` on the **50% test set**. And later a *RMSE* of `0.063` on the **final test set** on Kaggle.

```{r}
#| eval: false
library(xgboost)

# Load the trained model
xgb_model <- readRDS("xgb_model.rds")

# Load the tuning results
xgb_tuned <- readRDS("xgb_tuned_results.rds")

# Make predictions on the test set
test_dmatrix <- xgb.DMatrix(data = test_matrix)
test_pred <- predict(xgb_model, test_dmatrix)

# For the scoring data, convert to DMatrix and make predictions
scoring_matrix <- as.matrix(test_final)
scoring_dmatrix <- xgb.DMatrix(data = scoring_matrix)
scoring_pred <- predict(xgb_model, scoring_dmatrix)

# --- Inverse Box-Cox Transformation ---
if (lambda == 0) {
  scoring_pred <- exp(scoring_pred)
} else {
  scoring_pred <- (scoring_pred * lambda + 1)^(1 / lambda) - 1
}

# Create submission file
submission <- data.frame(id = test$id, CTR = scoring_pred)
write.csv(submission, "xgboost_submission.csv", row.names = FALSE)

```

# Final Comment

A lot of experience and insights were gained during this project. There are several things that I did correctly and incorrectly that will be mentioned below.

##### Model Selection

If I had the opportunity to revisit this project, I would dedicate more effort to understanding the underlying patterns in the data rather than focusing solely on creating the most optimized model. During the process, I allocated significant time to understanding and applying basic feature engineering, experimenting with different models from **linear regression** to **decision tree**, and extensively tuning them to reduce the RMSE. Although the dataset was not the most complex, exploring the data first instead of jumping directly into modeling would not only be a time saver, but also give me deeper insight of the data to make more informed decisions throughout the process.

##### Data Exploration

In hindsight, I would prioritize more creative exploration of the data. For instance, I would experiment with binning continuous variables into categorical ones, exploring transformations such as **interactions between variables** (e.g., feature_a \* feature_b), and deriving insights from unique patterns in the data. Additionally, I would investigate the relationship between the variables through **correlation grids** and analyze properties like the distribution of categories or the length of specific fields to uncover hidden relationships. This exploratory approach could have revealed insights that were missed.

##### Model Fitting

I would also spend more time analyzing overfitting in the models. Throughout the project, my models consistently showed RMSE values that were approximately `10%` better on test data compared to the final data and `20%` better on training data compared to the test data. This highlights **significant overfitting** issues that I did not fully address. A deeper exploration of feature selection, regularization techniques, or more effective validation strategies could have helped mitigate this problem.
