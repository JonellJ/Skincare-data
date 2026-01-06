/* ============================================================= */
/* 0. IMPORT DATA                                                 */
/*    - Reads cosmetics.csv into SAS                              */
/* ============================================================= */
PROC IMPORT DATAFILE='data/cosmetics.csv'
    OUT=work.myMakeup_raw
    DBMS=CSV
    REPLACE;
    GUESSINGROWS=MAX;
RUN;

proc contents data=work.myMakeup_raw; 
run;


/* ============================================================= */
/* DATA CLEANING: REMOVE DUPLICATES                              */
/*    - Removes duplicate products based on Brand + Label         */
/* ============================================================= */
proc sort data=work.myMakeup_raw 
          out=work.myMakeup_sorted nodupkey;
    by brand label;
run;


/* ============================================================= */
/* Q1: PREMIUM VS BUDGET BRAND CLASSIFICATION                    */
/*    - Creates "brand_type" column (Premium/Budget)              */
/*    - Based on price >= 25 cutoff                               */
/* ============================================================= */
proc rank data=work.myMakeup_sorted out=work.price_rank groups=2;
    var price;
    ranks price_group;
run;

data work.Makeup_flagged;
    set work.myMakeup_sorted;

    /* Assign brand type based on price */
    if price >= 25 then brand_type = "Premium";
    else brand_type = "Budget";
run;


/* ============================================================= */
/* Q2: INGREDIENT COMPLEXITY                                     */
/*    - Creates ingredient_count (# of ingredients per product)   */
/* ============================================================= */
data work.Makeup_complexity;
    set work.Makeup_flagged;

    /* Count comma-separated ingredients */
    ingredient_count = countw(ingredients, ',');
run;


/* ============================================================= */
/* Q2B: DO PREMIUM BRANDS HAVE MORE INGREDIENTS?                 */
/*    - T-test comparing ingredient_count between brand types     */
/* ============================================================= */
proc ttest data=work.Makeup_complexity;
    class brand_type;
    var ingredient_count;
run;


/* ============================================================= */
/* Q3: CORRELATION BETWEEN PRICE & RANK                          */
/*    - Pearson correlation                                       */
/* ============================================================= */
proc corr data=work.Makeup_complexity;
    var price rank;
run;


/* ============================================================= */
/* Q3B: REGRESSION: DOES PRICE PREDICT PRODUCT RANK?             */
/* ============================================================= */
proc reg data=work.Makeup_complexity;
    model rank = price;
run;


/* ============================================================= */
/* Q4: DOES PRICE RELATE TO SENSITIVE-SKIN PRODUCTS?             */
/*    - Correlation: price vs Sensitive                           */
/* ============================================================= */
proc corr data=work.Makeup_complexity;
    var price sensitive;
run;


/* ============================================================= */
/* Q5: PRICE VARIANCE ACROSS BRANDS                              */
/*    - Shows mean & variance of price by brand                   */
/* ============================================================= */
proc means data=work.Makeup_complexity n mean var;
    class brand;
    var price;
run;


/* ============================================================= */
/* Q6: WHICH BRANDS SUPPORT ALL 5 SKIN TYPES?                    */
/*    - Checks if brand has at least 1 product for each type      */
/*    - Creates covers_all flag (1 = yes, 0 = no)                 */
/* ============================================================= */
proc sql;
    create table work.brand_skin as
    select brand,
           sum(oily) as oily_cnt,
           sum(dry) as dry_cnt,
           sum(normal) as normal_cnt,
           sum(combination) as combo_cnt,
           sum(sensitive) as sens_cnt
    from work.Makeup_complexity
    group by brand;
quit;

data work.brand_skin_flag;
    set work.brand_skin;

    /* Brand must have at least one item for all 5 skin types */
    if oily_cnt>0 and dry_cnt>0 and normal_cnt>0 
       and combo_cnt>0 and sens_cnt>0 then covers_all=1;
    else covers_all=0;
run;

proc print data=work.brand_skin_flag;
run;


/* ============================================================= */
/* Q7: DO CERTAIN BRANDS CONSISTENTLY RANK HIGHER?               */
/*    - Average Rank per Brand                                    */
/* ============================================================= */
proc summary data=work.Makeup_complexity nway;
    class Brand;
    var Rank;
    output out=Brand_Rank_Summary mean=AvgRank;
run;

proc print data=Brand_Rank_Summary;
    title "Average Rank per Brand";
run;


/* ============================================================= */
/* Q7B: ANOVA — ARE BRAND RANK DIFFERENCES SIGNIFICANT?          */
/* ============================================================= */
proc glm data=work.Makeup_complexity;
    class Brand;
    model Rank = Brand;
    title "ANOVA: Rank Differences Across Brands";
run;
quit;


/* ============================================================= */
/* Q8: DOES INGREDIENT COMPLEXITY PREDICT RANK? (REGRESSION)     */
/* ============================================================= */
proc reg data=work.Makeup_complexity outest=RegResults noprint;
    model Rank = ingredient_count;
run;
quit;

proc print data=RegResults;
    title "Regression Summary: Rank = ingredient_count";
run;


/* ============================================================= */
/* Q8B: SCATTERPLOT OF INGREDIENT COUNT VS RANK                  */
/* ============================================================= */
proc sgplot data=work.Makeup_complexity;
    scatter x=ingredient_count y=Rank;
    reg x=ingredient_count y=Rank;
    title "Scatterplot: Ingredient Count vs Rank";
run;

proc export data=work.Makeup_complexity
    outfile="outputs/Makeup_for_Tableau.xlsx"
    dbms=xlsx replace;
run;
