Skincare Product Data Analysis
This project analyzes a dataset of 1,400+ skincare products using SAS and SQL (PROC SQL) to explore relationships between price, ingredient complexity, brand positioning, skin-type inclusivity, and product rank. Statistical testing and visualization were used to evaluate whether commonly assumed quality indicators meaningfully predict product performance.

Project Overview
The analysis focuses on answering key business and consumer-facing questions, including:
Do premium-priced products rank higher than budget products?
Do premium brands use more complex ingredient formulations?
Does price or ingredient count meaningfully predict product rank?
Which brands support all major skin types (oily, dry, normal, combination, sensitive)?
Are ranking differences across brands statistically significant?

Data & Methods

Dataset
1,400+ skincare products
Variables include price, brand, ingredients, rank, and skin-type indicators

Methods
Data cleaning and deduplication
Feature engineering (ingredient count, brand type)
Statistical analysis:
T-tests
Correlation analysis
Linear regression
ANOVA
Data exports for visualization in Tableau

Key Findings
Price and ingredient count are often statistically significant predictors but explain little variance in product rank (low R²).
Ingredient complexity does not strongly correlate with higher rankings.
Brand-level differences in rank are statistically significant, suggesting brand positioning matters more than price alone.
Only a subset of brands consistently support all five major skin types.
