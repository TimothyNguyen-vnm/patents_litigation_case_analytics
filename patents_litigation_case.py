import pandas as pd
import matplotlib.pyplot as plt

# Load data
df = pd.read_csv("/Users/ducthanh/Desktop/patents_litigation_case/litigation_master_cleaned_data.csv")
 


### Step 1: Automated Validation
def validate_data(df):
    print("Running automated validation...\n")

    # Duplicate check
    duplicates = df.duplicated().sum()
    print(f"Duplicate rows: {duplicates}")

    # Missing values
    print("\nMissing values per column:")
    print(df.isnull().sum())

    # Logical check
    invalid_durations = df[df["case_duration_days"] < 0]
    print(f"\nInvalid durations found: {len(invalid_durations)}")

    print("\nValidation complete ✅")


# Check for duplicates - Duplicate rows: 1228

# Check missing values - no missing values per column

# Basic consistency check (duration_days >= 0) - Invalid durations found: 0

validate_data(df)


### Visualization 

# Convert filed dates to datetime
df['date_filed'] = pd.to_datetime(df['date_filed'], errors='coerce')
# Extract filing year
df['year_filed'] = df['date_filed'].dt.year

# Filter out invalid or 1900 years
df = df[(df['year_filed'].notna()) & (df['year_filed'] != 1900)]
# --- Cases per year ---
cases_per_year = df['year_filed'].value_counts().sort_index()


# --- Plot 1: Bar Chart ---
plt.figure(figsize=(12,6))
cases_per_year.plot(kind='bar', color='skyblue', edgecolor='black')
plt.title("Number of Cases Filed per Year - Bar Chart")
plt.xlabel("Year")
plt.ylabel("Number of Cases")
plt.tight_layout()
plt.show()

# --- Plot 2: Line Chart ---
plt.figure(figsize=(12,6))
cases_per_year.plot(kind='line', marker='o', color='darkblue')
plt.title("Number of Cases Filed per Year - Line Chart")
plt.xlabel("Year")
plt.ylabel("Number of Cases")
plt.grid(True, linestyle='--', alpha=0.7)
plt.tight_layout()
plt.show()

# Top 10 defendants
top_defendants = df["n_defendants"].value_counts().head(10)

top_defendants.plot(kind="bar", figsize=(10,6))
plt.title("Top 10 Most Common Number of Defendants per Case")
plt.xlabel("Number of Defendants")
plt.ylabel("Frequency")
plt.tight_layout()
plt.show()







