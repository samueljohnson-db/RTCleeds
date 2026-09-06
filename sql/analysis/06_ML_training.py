# this will contain python code that can be used within google collab using jupyter notebook to train and produce predictive ML models #
# this code works with the finished master document weather and incidents.csv file found under the data/cleaned folder #
# -*- coding: utf-8 -*-

importance.plot(
    x="Feature",
    y="Importance",
    kind="barh",
    figsize=(10, 7)
)

plt.title(
    "Random Forest Feature Importance"
)

plt.xlabel("Importance")
plt.ylabel("Feature")

plt.gca().invert_yaxis()

plt.show()

feature_names = rf_B_pipeline.named_steps['preprocessor'].get_feature_names_out()

importance = pd.DataFrame({
    "Feature": feature_names,
    "Importance": rf_B_pipeline.named_steps['classifier'].feature_importances_
})

importance = importance.sort_values(
    "Importance",
    ascending=False
)

importance

"""feature importance

"""

results = pd.DataFrame({
    "Model": [
        "Logistic Regression A",
        "Logistic Regression B",
        "Random Forest A",
        "Random Forest B"
    ],

    "Balanced Accuracy": [
        balanced_accuracy_score(
            y_test, pred_log_A
        ),
        balanced_accuracy_score(
            y_test, pred_log_B
        ),
        balanced_accuracy_score(
            y_test, pred_rf_A
        ),
        balanced_accuracy_score(
            y_test, pred_rf_B
        )
    ],

    "Macro F1": [
        f1_score(
            y_test, pred_log_A,
            average="macro"
        ),
        f1_score(
            y_test, pred_log_B,
            average="macro"
        ),
        f1_score(
            y_test, pred_rf_A,
            average="macro"
        ),
        f1_score(
            y_test, pred_rf_B,
            average="macro"
        )
    ],

    "Macro Recall": [
        recall_score(
            y_test, pred_log_A,
            average="macro"
        ),
        recall_score(
            y_test, pred_log_B,
            average="macro"
        ),
        recall_score(
            y_test, pred_rf_A,
            average="macro"
        ),
        recall_score(
            y_test, pred_rf_B,
            average="macro"
        )
    ]
})

results

"""comparison of model a and b above

"""

print(
    classification_report(
        y_test,
        pred_rf_B
    )
)

plt.figure(figsize=(7, 5))

sns.heatmap(
    cm,
    annot=True,
    fmt="d"
)

plt.xlabel("Predicted Severity")
plt.ylabel("Actual Severity")
plt.title(
    "Random Forest Model B - Confusion Matrix"
)

plt.show()

cm = confusion_matrix(
    y_test,
    pred_rf_B
)

"""Final random Forest"""

evaluate_model(
    "Logistic Regression - Model A",
    y_test,
    pred_log_A
)

evaluate_model(
    "Logistic Regression - Model B",
    y_test,
    pred_log_B
)

evaluate_model(
    "Random Forest - Model A",
    y_test,
    pred_rf_A
)

evaluate_model(
    "Random Forest - Model B",
    y_test,
    pred_rf_B
)

def evaluate_model(name, y_true, y_pred):

    print("=" * 60)
    print(name)
    print("=" * 60)

    print(
        "Accuracy:",
        round(
            accuracy_score(y_true, y_pred),
            3
        )
    )

    print(
        "Balanced Accuracy:",
        round(
            balanced_accuracy_score(y_true, y_pred),
            3
        )
    )

    print(
        "Macro F1:",
        round(
            f1_score(
                y_true,
                y_pred,
                average="macro"
            ),
            3
        )
    )

    print(
        "Macro Precision:",
        round(
            precision_score(
                y_true,
                y_pred,
                average="macro"
            ),
            3
        )
    )

    print(
        "Macro Recall:",
        round(
            recall_score(
                y_true,
                y_pred,
                average="macro"
            ),
            3
        )
    )

    print("\nClassification Report:")
    print(
        classification_report(
            y_true,
            y_pred
        )
    )

"""Testing all four models"""

rf_A_pipeline.fit(
    X_train_A,
    y_train
)

pred_rf_A = rf_A_pipeline.predict(
    X_test_A
)

print("--- Evaluation for Random Forest Model A ---")
print("Accuracy Score (Random Forest A):", accuracy_score(y_test, pred_rf_A))
print("Balanced Accuracy Score (Random Forest A):", balanced_accuracy_score(y_test, pred_rf_A))
print("\nClassification Report (Random Forest A):\n", classification_report(y_test, pred_rf_A))

rf_B_pipeline = Pipeline([
    ('preprocessor', preprocessor_B),
    ('classifier', RandomForestClassifier(
        n_estimators=300,
        class_weight="balanced",
        random_state=42,
        n_jobs=-1
    ))
])

rf_B_pipeline.fit(
    X_train_B,
    y_train
)

pred_rf_B = rf_B_pipeline.predict(
    X_test_B
)

print("\n--- Evaluation for Random Forest Model B ---")
print("Accuracy Score (Random Forest B):", accuracy_score(y_test, pred_rf_B))
print("Balanced Accuracy Score (Random Forest B):", balanced_accuracy_score(y_test, pred_rf_B))
print("\nClassification Report (Random Forest B):\n", classification_report(y_test, pred_rf_B))

rf_A_pipeline = Pipeline([
    ('preprocessor', preprocessor_A),
    ('classifier', RandomForestClassifier(
        n_estimators=300,
        class_weight="balanced",
        random_state=42,
        n_jobs=-1
    ))
])

"""Random FOREST Model A

"""

logistic_B.fit(
    X_train_B,
    y_train
)

columns_to_check_for_nan = [
    "CASUALTY_SEVERITY",
    "hour",
    "month",
    "day_of_week",
    "is_weekend",
    "season",
    "WEATHER_CODE",
    "WX_WIND_SPD_12M_MS",
    "WX_WIND_STD",
    "WX_TEMP_8M_DEGC",
    "WX_TEMP_DIFF_2M",
    "WX_GLOB_RAD_WM2",
    "WX_REL_HUM_PCT"
]
incident_df = incident_df.dropna(subset=columns_to_check_for_nan)

pred_log_B = logistic_B.predict(
    X_test_B
)

print("\n--- Evaluation for Logistic Regression Model B ---")
print("Accuracy Score (Model B):", accuracy_score(y_test, pred_log_B))
print("Balanced Accuracy Score (Model B):", balanced_accuracy_score(y_test, pred_log_B))
print("\nClassification Report (Model B):\n", classification_report(y_test, pred_log_B))

fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Confusion Matrix for Model A
sns.heatmap(confusion_matrix(y_test, pred_log_A), annot=True, fmt='d', cmap='Blues', ax=axes[0])
axes[0].set_title('Confusion Matrix - Logistic A')
axes[0].set_xlabel('Predicted Label')
axes[0].set_ylabel('True Label')

# Confusion Matrix for Model B
sns.heatmap(confusion_matrix(y_test, pred_log_B), annot=True, fmt='d', cmap='Blues', ax=axes[1])
axes[1].set_title('Confusion Matrix - Logistic B')
axes[1].set_xlabel('Predicted Label')
axes[1].set_ylabel('True Label')

plt.tight_layout()
plt.show()

fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Confusion Matrix for Model A
sns.heatmap(confusion_matrix(y_test, pred_log_A), annot=True, fmt='d', cmap='Blues', ax=axes[0])
axes[0].set_title('Confusion Matrix - Logistic A')
axes[0].set_xlabel('Predicted Label')
axes[0].set_ylabel('True Label')

# Confusion Matrix for Model B
sns.heatmap(confusion_matrix(y_test, pred_log_B), annot=True, fmt='d', cmap='Blues', ax=axes[1])
axes[1].set_title('Confusion Matrix - Logistic B')
axes[1].set_xlabel('Predicted Label')
axes[1].set_ylabel('True Label')

plt.tight_layout()
plt.show()

pred_log_B = logistic_B.predict(
    X_test_B
)

numerical_features_B = [
    'hour',
    'month',
    'day_of_week',
    'is_weekend',
    'WX_WIND_SPD_12M_MS',
    'WX_WIND_STD',
    'WX_TEMP_8M_DEGC',
    'WX_TEMP_DIFF_2M',
    'WX_GLOB_RAD_WM2',
    'WX_REL_HUM_PCT'
]
categorical_features_B = ['season', 'WEATHER_CODE']

preprocessor_B = ColumnTransformer(
    transformers=[
        ('num', StandardScaler(), numerical_features_B),
        ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_features_B)
    ])

logistic_B = Pipeline([
    ('preprocessor', preprocessor_B),
    ('classifier', LogisticRegression(
        class_weight='balanced',
        max_iter=1000,
        random_state=42
    ))
])

"""LOGISTIC REGRESSION FOR MODEL B"""

pred_log_A = logistic_A.predict(
    X_test_A
)

print("Evaluation for Logistic Regression Model A ")
print("Accuracy Score (Model A):", accuracy_score(y_test, pred_log_A))
print("Balanced Accuracy Score (Model A):", balanced_accuracy_score(y_test, pred_log_A))
print("\nClassification Report (Model A):\n", classification_report(y_test, pred_log_A))

logistic_A.fit(
    X_train_A,
    y_train
)

numerical_features = ['hour', 'month', 'day_of_week', 'is_weekend']
categorical_features = ['season']

preprocessor_A = ColumnTransformer(
    transformers=[
        ('num', StandardScaler(), numerical_features),
        ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_features)
    ])

logistic_A = Pipeline([
    ('preprocessor', preprocessor_A),
    ('classifier', LogisticRegression(
        class_weight='balanced',
        max_iter=1000,
        random_state=42
    ))
])

"""LOGISTIC REGRESSION ABOVE for MODEL A

"""

X_train_A = X_A.iloc[train_idx]
X_test_A = X_A.iloc[test_idx]

X_train_B = X_B.iloc[train_idx]
X_test_B = X_B.iloc[test_idx]

y_train = y.iloc[train_idx]
y_test = y.iloc[test_idx]
# this ensures that model a and b will be evaluated on exactly the same incidents.

train_idx, test_idx = train_test_split(
    np.arange(len(y)),
    test_size=0.20,
    random_state=42,
    stratify=y
)

X_train_A, X_test_A, y_train, y_test = train_test_split(
    X_A,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)

# This cell is now redundant as comprehensive NaN removal is handled earlier.

# This cell is now redundant as comprehensive NaN removal is handled earlier.

y.value_counts()

"""testing"""

X_B = incident_df[
    [
        "hour",
        "month",
        "day_of_week",
        "is_weekend",
        "season",
        "WEATHER_CODE",
        "WX_WIND_SPD_12M_MS",
        "WX_WIND_STD",
        "WX_TEMP_8M_DEGC",
        "WX_TEMP_DIFF_2M",
        "WX_GLOB_RAD_WM2",
        "WX_REL_HUM_PCT"
    ]
].copy()

"""MODEL-B ABOVE"""

y = incident_df["CASUALTY_SEVERITY"]

X_A = incident_df[
    [
        "hour",
        "month",
        "day_of_week",
        "is_weekend",
        "season"
    ]
].copy()

"""MODEL-A ABOVE"""

h_stat, p_value = kruskal(*groups)

print("Kruskal-Wallis H:", h_stat)
print("p-value:", p_value)

daily_incidents.groupby(
    "weather_condition"
)["incident_count"].describe()

f_stat, p_value = f_oneway(*groups)

print("F-statistic:", f_stat)
print("p-value:", p_value)

groups = [
    group["incident_count"].values
    for _, group
    in daily_incidents.groupby("weather_condition")
]

"""ANOVA TEST ABOVE"""

daily_incidents.head()

daily_incidents = (
    incident_df
    .groupby(["date", "weather_condition"])
    .size()
    .reset_index(name="incident_count")
)

incident_df["date"] = (
    incident_df["INC_TIMESTAMP"].dt.date
)

"""above is incident frequncy for each weather condition on a daily incident count"""

n = contingency_table.to_numpy().sum()

phi2 = chi2 / n

r, k = contingency_table.shape

cramers_v = np.sqrt(
    phi2 / min(k - 1, r - 1)
)

print("Cramér's V:", cramers_v)

expected_df = pd.DataFrame(
    expected,
    index=contingency_table.index,
    columns=contingency_table.columns
)

expected_df

chi2, p, dof, expected = chi2_contingency(
    contingency_table
)

print("Chi-square:", chi2)
print("Degrees of freedom:", dof)
print("p-value:", p)

contingency_table = pd.crosstab(
    incident_df["weather_condition"],
    incident_df["CASUALTY_SEVERITY"]
)

contingency_table

severity_counts.plot(kind="bar")

plt.title("Incident Severity Distribution")
plt.xlabel("Severity")
plt.ylabel("Number of Incidents")
plt.show()

severity_percentage = (
    incident_df["CASUALTY_SEVERITY"]
    .value_counts(normalize=True)
    .mul(100)
    .round(2)
)

severity_percentage

severity_counts = (
    incident_df["CASUALTY_SEVERITY"]
    .value_counts()
    .sort_index()
)

severity_counts

weather_labels = {

    1: "Fine without high winds",
    2: "Raining without high winds",
    3: "Snowing without high winds",
    4: "Fine with high winds",
    5: "Raining with high winds",
    6: "Snowing with high winds",
    7: "Fog or mist",
    8: "Other",
    9: "Unknown",

}

incident_df["weather_condition"] = (
    incident_df["WEATHER_CODE"]
    .map(weather_labels)
)

columns_to_check_for_nan = [
    "CASUALTY_SEVERITY",
    "hour",
    "month",
    "day_of_week",
    "is_weekend",
    "season",
    "WEATHER_CODE",
    "WX_WIND_SPD_12M_MS",
    "WX_WIND_STD",
    "WX_TEMP_8M_DEGC",
    "WX_TEMP_DIFF_2M",
    "WX_GLOB_RAD_WM2",
    "WX_REL_HUM_PCT"
]
incident_df = incident_df.dropna(subset=columns_to_check_for_nan)

incident_df["WEATHER_CODE"].value_counts().sort_index()

def get_season(month):
    if month in [12, 1, 2]:
        return "Winter"
    elif month in [3, 4, 5]:
        return "Spring"
    elif month in [6, 7, 8]:
        return "Summer"
    else:
        return "Autumn"

incident_df["season"] = (
    incident_df["month"].apply(get_season)
)

incident_df["is_weekend"] = (
    incident_df["day_of_week"] >= 5
).astype(int)

incident_df["hour"] = incident_df["INC_TIMESTAMP"].dt.hour

incident_df["month"] = incident_df["INC_TIMESTAMP"].dt.month

incident_df["day_of_week"] = (
    incident_df["INC_TIMESTAMP"].dt.dayofweek
)

incident_df["INC_TIMESTAMP"].max()

incident_df["INC_TIMESTAMP"].min()

incident_df["INC_TIMESTAMP"] = pd.to_datetime(
    incident_df["INC_TIMESTAMP"],
    dayfirst=True,
    errors="coerce"
)

incident_df[
    "WEATHER_TIME_GAP_MINUTES"
].hist(bins=30)

plt.xlabel("Weather Time Gap (minutes)")
plt.ylabel("Number of Incidents")
plt.title("Distribution of Incident–Weather Timestamp Differences")
plt.show()

incident_df["WEATHER_TIME_GAP_MINUTES"].isna().sum()

incident_df["WEATHER_TIME_GAP_MINUTES"].value_counts().sort_index().head(20)

incident_df["WEATHER_TIME_GAP_MINUTES"].describe()

incident_df["CASUALTY_SEVERITY"].value_counts()

incident_df.head()

incident_df.shape

incident_df = (
    df.groupby("REFERENCE_NUMBER")
      .agg({
          "CASUALTY_SEVERITY": "min",
          "INC_TIMESTAMP": "first",
          "WX_TIMESTAMP": "first",
          "WEATHER_CODE": "first",
          "WX_WIND_DIR_12M": "first",
          "WX_WIND_SPD_12M_MS": "first",
          "WX_WIND_STD": "first",
          "WX_TEMP_8M_DEGC": "first",
          "WX_TEMP_DIFF_2M": "first",
          "WX_GLOB_RAD_WM2": "first",
          "WX_REL_HUM_PCT": "first",
          "WEATHER_TIME_GAP_MINUTES": "first",
          "NUMBER_OF_VEHICLES": "first",
          "ROAD_CLASS": "first",
          "ROAD_SURFACE_CODE": "first",
          "LIGHTING_CODE": "first"
      })
      .reset_index()
)

df["REFERENCE_NUMBER"].value_counts().head(20)

len(df)

df["REFERENCE_NUMBER"].nunique()

df.columns.tolist()

df.shape

df.head()

df = pd.read_csv(
    "/content/finished master document weather and incidents.csv"
)

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

from scipy.stats import chi2_contingency
from scipy.stats import f_oneway
from scipy.stats import kruskal

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline

from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier

from sklearn.metrics import (
    accuracy_score,
    balanced_accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
    roc_auc_score,
    average_precision_score
)

from sklearn.inspection import permutation_importance

import warnings
warnings.filterwarnings("ignore")
