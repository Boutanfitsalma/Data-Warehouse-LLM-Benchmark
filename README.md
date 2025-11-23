# 📊 Data Warehouse for LLM Benchmark Evaluation

[![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/sql-server)
[![SSIS](https://img.shields.io/badge/SSIS-CC2927?style=for-the-badge&logo=microsoft&logoColor=white)](https://docs.microsoft.com/sql/integration-services/)
[![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)


## 🎯 Project Overview

Academic Data Warehouse project for the **EvalLLM consortium** to analyze and compare the performance of Large Language Models (LLMs) across multiple benchmarks.

This project transforms raw evaluation data from a CSV file (4,576 records) into a structured dimensional model, enabling comprehensive multidimensional analysis of LLM performance metrics.

### 🔑 Key Achievements
- **Star schema** with 2 fact tables and 3 dimensions
- **4,576 evaluations** processed and analyzed
- **6 benchmarks** tracked (IFEval, BBH, MATH, GPQA, MUSR, MMLU-PRO)
- **SCD Type 2** implementation for model evolution tracking
- **Automated ETL** pipeline using SSIS

---

## 📊 Architecture

### Data Model

The solution follows a **star schema** design:

**Fact Tables:**
- `FactBenchmarkEvaluation` - Detailed scores per model-benchmark combination
- `FactModelEvaluationScore` - Aggregated model performance metrics

**Dimensions:**
- `DimModel` - Model characteristics (architecture, parameters, license, etc.)
  - Implements **SCD Type 2** for historical tracking
- `DimBenchmark` - Benchmark information and categories
- `DimDate` - Standard time dimension

### Key Metrics

- **Performance Scores**: Raw and normalized scores per benchmark
- **Average Score**: Global model performance (average: 21.81)
- **Environmental Impact**: CO2 cost per model (average: 3.96 kg)
- **Model Popularity**: HubHearts count
- **Model Size**: Parameters in billions

---

## 🛠️ Technologies

| Technology | Purpose |
|------------|---------|
| **SQL Server** | Data warehouse storage and management |
| **SSIS (SQL Server Integration Services)** | ETL process automation |
| **Power BI** | Interactive dashboards and visualizations |
| **Visual Studio** | SSIS package development |

---

## 📈 Key Findings

### Model Performance
- Top performing models: **llama/13**, **fbigpt7b**, **Qwen7b** (40-50 points)
- Average performance across all models: **21.81**
- No direct correlation between CO2 cost and performance

### Model Size Evolution
- Stabilization in model size since July 2024
- Initial peak at 60 billion parameters
- Industry shift from size to architectural improvements

### Benchmark Difficulty
- **IFEval** (Instruction Following): Most challenging
- **Google-PACT QA**: Least challenging
- Provides clear improvement targets

### Popularity vs. Performance
- Most used models (e.g., meta/llama with 5000+ users) aren't always top performers
- Indicates factors beyond technical excellence drive adoption

---

## 📁 Project Structure
```
Data-Warehouse-LLM-Benchmark/
│
├── 📄 README.md
│
├── 📁 docs/
│   └── Rapport_Projet_DW.pdf           # Complete project report (French)
│
├── 📁 SQL/
│   ├── 01_create_database.sql
│   ├── 02_create_staging.sql
│   ├── 03_create_dimensions.sql
│   ├── 04_create_facts.sql
│   └── 05_populate_date_dimension.sql
│
├── 📁 ssis/
│   └── package_documentation.md        # SSIS package descriptions

```

---

## 🚀 ETL Process

### 1. Staging Area
- CSV data extraction to SQL staging tables
- Data type conversion and validation
- 4,576 rows processed

### 2. Dimension Loading
- **DimModel**: SCD Type 2 implementation for historical tracking
- **DimBenchmark**: Static dimension with 6 benchmark categories
- **DimDate**: Generated programmatically with full calendar attributes

### 3. Fact Loading
- **FactBenchmarkEvaluation**: Detailed evaluations (27,456 records)
- **FactModelEvaluationScore**: Aggregated model metrics (4,576 records)
- Referential integrity maintained through surrogate keys

---

## 📊 Business Intelligence Insights

### Performance Analysis
- Benchmark difficulty ranking enables targeted improvements
- Evolution tracking shows industry trends
- Comparative analysis across architectures and model sizes

### Environmental Sustainability
- CO2 cost tracking promotes eco-friendly development
- No performance penalty for lower environmental impact
- Identifies efficient model architectures

### Strategic Decision Support
- Popularity vs. performance gap analysis
- ROI evaluation (performance vs. cost)
- Trend identification for future investments

---

## 🎓 Academic Context

- **Institution**: ENSIAS (National School of Computer Science and Systems Analysis)
- **Program**: Business Intelligence & Analytics (1st year)
- **Team**: 
  - JENNANE Salma
  - MICHAAL Yassine
  - BOUTANFIT Salma
- **Supervisor**: Madame BENHIBA
- **Academic Year**: 2024-2025

---

## 🔮 Future Enhancements

### Immediate Improvements
1. **Real-time Integration**
   - Automated data refresh from HuggingFace API
   - Live dashboard updates

2. **Expanded Benchmarks**
   - Integration of additional evaluation frameworks
   - Custom benchmark support

### Long-term Vision
1. **Predictive Analytics**
   - Performance trend forecasting
   - Architecture success prediction

2. **Collaborative Platform**
   - Community-driven benchmark submissions
   - Shared evaluation standards

3. **Automated Testing**
   - Continuous evaluation pipeline
   - New model auto-benchmarking

---


## 🙏 Acknowledgments

Special thanks to:
- **Madame BENHIBA** for academic supervision
- **EvalLLM Consortium** for the use case
- **ENSIAS** for providing the learning environment
- **Papers with Code** and **HuggingFace** for benchmark data


---

<p align="center">
  <sub>⭐ If you find this project interesting, please consider giving it a star!</sub>
</p>
