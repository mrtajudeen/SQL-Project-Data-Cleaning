# 🧹 Layoffs Data Cleaning Project (SQL)

Welcome to the **Layoffs Data Cleaning Project**, where we clean and prepare a dataset of company layoffs from 2022 for meaningful analysis and insights using **SQL**.  
The data was sourced from **Kaggle** and went through a comprehensive cleaning pipeline to ensure **accuracy**, **consistency**, and **usability**.

📦 **Source**: [Kaggle - Layoffs 2022 Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)

---

## 🧠 Project Objective

The goal of this project is to clean raw layoff data using SQL.  
We remove inconsistencies, handle duplicates and nulls, standardize values, and drop irrelevant information.  
By the end of this process, we produce a **clean, analysis-ready dataset** that can be used for data exploration and reporting.

---

## ⚙️ Tools Used

- **MySQL**
- **SQL functions** and **window operations**
- **Common Table Expressions (CTEs)**

---

## 🧼 Data Cleaning Steps

The project followed a structured **4-step data cleaning process**:

---

### 1. 🗑️ Remove Duplicates

- Identified duplicate records based on key attributes (company, location, industry, etc.)
- Used `ROW_NUMBER()` to flag duplicates and retained only the first occurrence
- Deleted duplicate rows to ensure data integrity

---

### 2. 🧽 Standardization

- **Company Names**: Trimmed whitespace to standardize values  
- **Industry**: Merged inconsistent naming conventions (e.g., `"Crypto"`, `"Cryptography"`) under a common label  
- **Country**: Fixed formatting issues like trailing punctuation (e.g., `"United States."` → `"United States"`)  
- **Dates**: Converted string formats (`MM/DD/YYYY`) to proper SQL `DATE` types

---

### 3. 🚫 Handling Null and Blank Values

- Replaced blank strings in categorical fields (e.g., `industry`) with `NULL`
- Imputed missing `industry` values by matching company and location
- Deleted rows with both `total_laid_off` **and** `percentage_laid_off` as `NULL`

---

### 4. ✂️ Removing Unnecessary Data

- Dropped rows with missing key layoff information
- Removed temporary/helper columns like `row_num` used during cleaning

---

## 📈 Final Result

After cleaning, the dataset was transformed into a well-structured table with:

- ✅ Consistent and standardized values across all columns  
- ✅ No duplicates  
- ✅ Minimal nulls  
- ✅ Correct data types  
- ✅ Ready for data exploration and visualization

---

## 📌 Next Steps

In the next phase, we’ll perform **data exploration** to answer important questions like:

- Which companies had the highest layoffs?  
- What industries were affected most?  
- Which countries saw the most layoff activity?  
- Are there any patterns over time?

> 📊 Stay tuned for the next notebook: **Data Exploration with SQL**

---

## 🏷️ Project Tags

`#SQL` `#DataCleaning` `#MySQL` `#Layoffs2022` `#ETL` `#DataPreparation` `#KaggleProject` `#DataAnalytics`

---

## 🤝 Contributions & Feedback

Have suggestions or want to contribute?  
Feel free to **fork the repo** and submit a **pull request**, or **open an issue**.  
Feedback is always welcome!

---
