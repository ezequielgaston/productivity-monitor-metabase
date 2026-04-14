# Warehouse Productivity Monitor | Metabase & SQL Analysis

### Project Overview
This project features a dynamic dashboard designed to monitor and analyze warehouse operational productivity. Using **SQL** and **Metabase**, I transformed raw logistics data into actionable insights, allowing for real-time tracking of fulfillment performance and year-over-year (YoY) comparisons.

### Key Objectives
* **Performance Tracking:** Visualize the total volume of packages processed (Current period: 2,574 units).
* **Comparative Analysis:** Measure productivity shifts against the previous year (identifying a -6.83% variation).
* **Bottleneck Identification:** Pinpoint peak operational hours and days to optimize staff allocation and resources.

### Technical Stack
* **Query Language:** SQL (Complex queries involving Joins, Common Table Expressions (CTEs), and Date transformations).
* **Visualization Tool:** Metabase.
* **Data Source:** Operational WMS (Warehouse Management System) databases.

### Dashboard Features & Insights
1.  **Productivity Heatmap:** * *Insight:* Data reveals that peak activity consistently occurs between **8:00 AM and 9:00 AM**.
    * *Benefit:* Allows management to ensure maximum staff availability during the morning rush.
2.  **Daily Participation:** * *Insight:* Monday is identified as the highest volume day, accounting for **22.2%** of weekly participation.
3.  **Year-over-Year (YoY) Comparison:** * A side-by-side bar chart (Actual vs. Past) helps detect growth patterns or anomalies in daily output.
4.  **Interactive Filters:** * Includes dynamic filtering by Business Unit, Date Range, Shipping Channel, and Shipping Type.

### Repository Structure
* `/sql_queries`: Contains the `.sql` scripts used to generate each dashboard card.
* `/screenshots`: High-resolution images of the final dashboard.
* `README.md`: Project documentation and business context.

### Challenges & Learning
One of the main challenges was normalizing date formats to ensure an accurate "Like-for-Like" comparison with the previous year. I implemented custom SQL logic to handle day-of-the-week alignment, ensuring the YoY variation reflected a true operational comparison rather than just calendar dates.

---
*Developed by Ezequiel Gastón Rodas*
