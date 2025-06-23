import streamlit as st
import pandas as pd
import plotly.express as px

# --- Load and clean data ---
df = pd.read_csv('layoffs_staging2.csv', sep=';')
df.columns = df.columns.str.lower().str.strip()
df['date'] = pd.to_datetime(df['date'], errors='coerce')
df = df.dropna(subset=['date'])

# --- App configuration ---
st.set_page_config(page_title="Layoffs Dashboard", layout="wide")
st.title("💼 Global Layoffs Analysis (2020–2023)")

# --- Temporal Trend ---
st.header("📊 Layoffs Over Time")

df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.to_period('M').astype(str)

yearly = df.groupby('year')['total_laid_off'].sum().reset_index()
monthly = df.groupby('month')['total_laid_off'].sum().reset_index()

fig_year = px.bar(yearly, x='year', y='total_laid_off',
                  title="Total Layoffs by Year", text_auto=True)
st.plotly_chart(fig_year, use_container_width=True)

fig_month = px.line(monthly, x='month', y='total_laid_off',
                    title="Monthly Layoffs Trend")
st.plotly_chart(fig_month, use_container_width=True)

# --- Industry Impact ---
st.header("🏭 Industry Breakdown")

industry_total = df.groupby('industry')['total_laid_off'].sum().reset_index()\
    .sort_values(by='total_laid_off', ascending=False).head(10)

fig_industry = px.bar(industry_total, x='industry', y='total_laid_off',
                      title="Top 10 Industries by Total Layoffs", text_auto=True)
st.plotly_chart(fig_industry, use_container_width=True)

# --- Geographic Impact ---
st.header("🌍 Geographic Perspective")

country_total = df.groupby('country')['total_laid_off'].sum().reset_index()\
    .sort_values(by='total_laid_off', ascending=False).head(10)

fig_country = px.bar(country_total, x='country', y='total_laid_off',
                     title="Top 10 Countries by Layoffs", text_auto=True)
st.plotly_chart(fig_country, use_container_width=True)

# --- Company Stage Analysis ---
st.header("🏢 Early vs Late Stage Companies")

early_stage = ['Series A', 'Series B', 'Series C']
early = df[df['stage'].isin(early_stage)]
late = df[~df['stage'].isin(early_stage)]

avg_early = early.groupby('company')['total_laid_off'].sum().mean()
avg_late = late.groupby('company')['total_laid_off'].sum().mean()

st.write(f"📌 Average Layoffs (Early Stage): `{avg_early:.2f}`")
st.write(f"📌 Average Layoffs (Late Stage): `{avg_late:.2f}`")

# --- Funding vs Layoffs ---
st.header("💸 Funding vs Layoffs (Correlation)")

funding_df = df.dropna(subset=['funds_raised_millions', 'total_laid_off'])
funding_sum = funding_df.groupby('company')[['total_laid_off', 'funds_raised_millions']]\
    .sum().reset_index()

fig_scatter = px.scatter(funding_sum,
                         x='funds_raised_millions',
                         y='total_laid_off',
                         hover_name='company',
                         title="Layoffs vs Funding Raised",
                         trendline='ols')
st.plotly_chart(fig_scatter, use_container_width=True)

# --- Data Table ---
st.header("🧾 Raw Data Preview")
st.dataframe(df.head(50))
