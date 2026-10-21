# 🗺️ Data Warehouse Project Roadmap

This roadmap outlines the complete agile execution lifecycle for this Medallion Architecture data warehouse project, tracking development from requirements analysis to target Gold layer delivery.

## 📋 1. Requirements Analysis & Architecture
- [x] Analyze & Understand the Requirements
- [x] Choose Data Management Approach
- [x] Design the Core Layers (Bronze, Silver, Gold)
- [x] Draw the Data Architecture Map (Draw.io)

## ⚙️ 2. Project Initialization
- [x] Map out Detailed Project Epics & Tasks (Notion)
- [x] Define Project Naming Conventions & Schema Blueprints
- [x] Initialize Git Repository & Prepare Directory Repo Structure
- [x] Create Core Database & Database Schemas in PostgreSQL

## 🟫 3. Build Bronze Layer (Raw Ingestion)
- [x] **Analyze:** Source Systems, File Extraction Constraints, & Column Types
- [x] **Code:** Data Ingestion Pipelines using Optimized Local `COPY` Scripts with `FREEZE`
- [x] **Validate:** Data Completeness Checks
- [x] **Document:** Map Data Lineage & Flow Visualizations (Draw.io)
- [x] **Commit:** Push Verified Ingestion Stored Procedure to Git Repository

## ⬜ 5. Build Silver Layer (Data Cleansing & Standardization)
- [x] **Analyze:** Explore & Understand Dirty Records, Nulls, & Historical Entries
- [x] **Document:** Map Out Data Integration Rules & Source-to-Target Schemas (Draw.io)
- [x] **Code:** Write Functional Data Cleansing, Case Standardization, & String Trimming Scripts
- [x] **Validate:** Data Correctness Checks
- [x] **Document:** Extend System Data Flow Diagram to Cover Cleaning Blocks (Draw.io)
- [x] **Commit:** Push Pipeline Transformations Stored Procedure to Git Repository

## 🟨 5. Build Gold Layer (Analytical Dimensional Modeling)
- [x] **Analyze:** Explore Target Business Objects & Analytical Subject Areas
- [x] **Code:** Construct Fact & Dimension Views and Star Schema Star Transformations (`dim_products`, `fact_sales`)
- [x] **Validate:** Data Integration, Foreign Key Matching, & Data Correctness Checks
- [x] **Document:** Draw Final Data Model Star Schema Architectural Diagram (Draw.io)
- [x] **Document:** Generate a Dynamic Data Catalog for Business Consumer Delivery
- [x] **Document:** Finalize Extended Overall Project End-to-End Data Flow Diagram (Draw.io)
- [x] **Commit:** Push Production-Ready Analytical Layer to Git Repository
