# Choice-Based Conjoint Analysis: Sports Car Preferences

A multinomial logit conjoint study analyzing how price, transmission, seating, and convertible availability drive sports car preference. Built as a quantitative research methods portfolio piece.

## What This Project Does

Uses choice-based conjoint (CBC) methodology to decompose consumer preference into the utility contribution of individual product attributes. The analysis estimates part-worth utilities, calculates relative attribute importance, and simulates market share under hypothetical competitive scenarios.

## Key Findings

| Attribute | Relative Importance |
|-----------|-------------------|
| Price | 50.9% |
| Transmission | 32.1% |
| Seating | 11.7% |
| Convertible | 5.4% |

- **Price and transmission account for 83% of what drives choice.** Everything else is secondary.
- **$40K is a psychological ceiling** — moving from $35K to $40K causes disproportionately more preference loss than $30K to $35K.
- **Manual transmission carries a severe penalty** — equivalent to a $10K+ price increase in preference impact.
- **5 seats meaningfully expand appeal** while the jump from 2 to 4 seats has zero effect.

## Dataset

Sports Car Choice Data from Chapman & Feit, *R for Marketing Research and Analytics* (Springer, 2015). Simulated CBC dataset with 200 respondents, 10 choice tasks each, 3 alternatives per task.

**Attributes:** Seating (2, 4, 5), Transmission (auto, manual), Convertible (yes, no), Price ($30K, $35K, $40K)

## Repository Contents

| File | Description |
|------|-------------|
| `sportscar_choice_long.csv` | Raw dataset in long format |
| `conjoint_analysis.R` | Full analysis script with data prep, model estimation, importance calculation, and market simulator |
| `conjoint_report.pdf` | Client-facing report with findings and strategic implications |

## Method

1. **Experimental design validation** — confirmed no position bias across alternatives, identified that `segment` is a between-subjects variable (not a product attribute) and excluded it from modeling
2. **Multinomial logit estimation** — estimated part-worth utilities using the `logitr` package in R with dummy-coded attributes
3. **Attribute importance** — calculated as each attribute's utility range relative to total range
4. **Market simulation** — predicted preference shares for hypothetical product configurations using the logit choice rule
5. **Price sensitivity** — modeled share erosion across price levels for the highest-utility configuration

## Tools

R 4.4.1, logitr (v1.1.3)

## Author

Adoksh — MS in Marketing Intelligence, University of San Francisco
