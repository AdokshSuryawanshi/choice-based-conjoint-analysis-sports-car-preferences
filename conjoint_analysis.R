# ============================================================
# Choice-Based Conjoint Analysis: Sports Car Preferences
# Date: March 6, 2026
# Author: Adoksh
# Dataset: Sports Car Choice Data (Chapman & Feit, 2015)
# Package: logitr
# ============================================================

# --- 1. LOAD AND PREPARE DATA --------------------------------

data <- read.csv("sportscar_choice_long.csv")

# Inspect structure
str(data)
head(data, 15)

# Convert categorical variables to factors
data$seat    <- as.factor(data$seat)
data$price   <- as.factor(data$price)
data$segment <- as.factor(data$segment)
data$trans   <- as.factor(data$trans)
data$convert <- as.factor(data$convert)

# Confirm factor conversion
str(data)

# --- 2. UNDERSTAND THE EXPERIMENTAL DESIGN -------------------

# Dataset: 200 respondents x 10 choice questions x 3 alternatives = 6000 rows
# Each question showed 3 hypothetical sports car profiles
# Respondent picked the one they'd most prefer (choice = 1)

# Attributes and levels:
#   seat:    2, 4, 5 (number of seats)
#   trans:   auto, manual (transmission type)
#   convert: yes, no (convertible top)
#   price:   30, 35, 40 (price in $000s)
#   segment: basic, fun, racer (does NOT vary within choice sets — 
#            this is a respondent-level segment label, not a product attribute)

# --- 3. CHECK FOR POSITION BIAS ------------------------------

# Verify choices are balanced across alternative positions
table(data$alt, data$choice)
# Result: ~656, 654, 690 — no position bias
# Justifies excluding intercept from the model

# --- 4. CREATE CHOICE SET IDENTIFIER -------------------------

# Each unique combination of resp_id + ques = one choice situation
data$chid     <- paste(data$resp_id, data$ques, sep = "_")
data$chid_num <- as.numeric(as.factor(data$chid))

# --- 5. DUMMY CODE ATTRIBUTES --------------------------------

# Explicit dummy coding for clean model specification
# Reference levels: seat = 2, trans = auto, convert = no, price = 30

data$seat4        <- ifelse(data$seat == "4", 1, 0)
data$seat5        <- ifelse(data$seat == "5", 1, 0)
data$trans_manual <- ifelse(data$trans == "manual", 1, 0)
data$convert_yes  <- ifelse(data$convert == "yes", 1, 0)
data$price35      <- ifelse(data$price == "35", 1, 0)
data$price40      <- ifelse(data$price == "40", 1, 0)

# --- 6. FIT MULTINOMIAL LOGIT MODEL --------------------------

# Note: segment is excluded because it does not vary within choice sets.
# It is a between-subjects variable (respondent characteristic), 
# not a within-choice-set product attribute. Including it causes
# a singular matrix because the model cannot estimate its effect
# from choice data where all 3 alternatives share the same segment.

library(logitr)

model <- logitr(
  data    = data,
  outcome = "choice",
  obsID   = "chid_num",
  pars    = c("seat4", "seat5", "trans_manual", 
              "convert_yes", "price35", "price40")
)

summary(model)

# --- 7. CALCULATE ATTRIBUTE IMPORTANCE -----------------------

# Part-worth utilities from model
coefs <- coef(model)

# For each attribute, importance = range of part-worths
# (include 0 for reference level)

seat_range    <- max(0, coefs["seat4"], coefs["seat5"]) - 
  min(0, coefs["seat4"], coefs["seat5"])

trans_range   <- max(0, coefs["trans_manual"]) - 
  min(0, coefs["trans_manual"])

convert_range <- max(0, coefs["convert_yes"]) - 
  min(0, coefs["convert_yes"])

price_range   <- max(0, coefs["price35"], coefs["price40"]) - 
  min(0, coefs["price35"], coefs["price40"])

# Total range across all attributes
total_range <- seat_range + trans_range + convert_range + price_range

# Relative importance (%)
importance <- data.frame(
  Attribute  = c("Seat", "Transmission", "Convertible", "Price"),
  Range      = round(c(seat_range, trans_range, convert_range, price_range), 3),
  Importance = round(c(seat_range, trans_range, convert_range, price_range) 
                     / total_range * 100, 1)
)

importance <- importance[order(-importance$Importance), ]
print(importance)

# --- 8. MARKET SHARE SIMULATOR -------------------------------

# Function to predict preference share for hypothetical products
# Each product is a named vector of dummy-coded attribute levels

predict_share <- function(products, coefs) {
  utilities <- sapply(products, function(p) sum(p * coefs))
  exp_utils <- exp(utilities)
  shares    <- exp_utils / sum(exp_utils)
  return(round(shares * 100, 1))
}

# Example simulation: 3 hypothetical cars competing in market

product_a <- c(seat4 = 0, seat5 = 1, trans_manual = 0, 
               convert_yes = 1, price35 = 0, price40 = 0)
# 5-seat, auto, convertible, $30K — "the crowd pleaser"

product_b <- c(seat4 = 1, seat5 = 0, trans_manual = 1, 
               convert_yes = 0, price35 = 1, price40 = 0)
# 4-seat, manual, no convertible, $35K — "the purist"

product_c <- c(seat4 = 0, seat5 = 0, trans_manual = 0, 
               convert_yes = 0, price35 = 0, price40 = 1)
# 2-seat, auto, no convertible, $40K — "the budget sports car"

products <- list(
  "Crowd Pleaser" = product_a, 
  "The Purist"    = product_b, 
  "Budget Sports" = product_c
)

shares <- predict_share(products, coefs)
print(data.frame(Product = names(shares), Share = shares))

# --- 9. SENSITIVITY ANALYSIS: PRICE EFFECT -------------------

# What happens to the Crowd Pleaser's share if we raise its price?

cat("\n--- Price Sensitivity for Crowd Pleaser ---\n")

for (price_level in list(
  list(name = "$30K", p35 = 0, p40 = 0),
  list(name = "$35K", p35 = 1, p40 = 0),
  list(name = "$40K", p35 = 0, p40 = 1)
)) {
  product_a_mod <- c(seat4 = 0, seat5 = 1, trans_manual = 0, 
                     convert_yes = 1, 
                     price35 = price_level$p35, 
                     price40 = price_level$p40)
  
  test_products <- list(
    "Crowd Pleaser" = product_a_mod, 
    "The Purist"    = product_b, 
    "Budget Sports" = product_c
  )
  
  s <- predict_share(test_products, coefs)
  cat(price_level$name, ":", s["Crowd Pleaser"], "% share\n")
}

# ============================================================
# END
# ============================================================