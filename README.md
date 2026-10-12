# Olist E-Commerce Performance & Customer Experience

End-to-end data analytics project using the Brazilian E-Commerce Public Dataset by Olist. The project turns raw e-commerce records into business insights on sales performance, delivery experience, freight burden, payment behaviour, and customer retention.

## Business objective

Understand what drives e-commerce performance beyond revenue by answering these questions:

- How did delivered order value change over time?
- Which customer states and product categories contribute the most revenue?
- How does delivery performance relate to customer reviews?
- Which categories carry a high freight burden?
- How concentrated are payment methods and repeat customers?

## Dashboard preview

The Power BI dashboard has two interactive pages and a shared date slicer.

1. **Overview** — sales KPIs, monthly revenue trend, customer-state revenue, payment contribution, and top product categories.
2. **Customer & Operations** — delivery risk, delivery duration by state, freight burden by category, and retention breakdown.

### Power BI dashboard file

[Download the Power BI dashboard (.pbix)](https://drive.google.com/file/d/1ycQl4VAjKzzUV_uye21P0gk2TNly45It/view?usp=sharing)

## Key results

| Metric | Result |
|---|---:|
| Delivered order value | 15.42M |
| Delivered orders | 96K |
| Average order value | 159.83 |
| Average review score | 4.16 / 5 |
| On-time delivery rate | 93.2% |
| Orders delivered 4+ days late | ~5K |
| One-time customers | 97% |

## Insights

- Revenue grew strongly through 2017. September–December 2016 and September 2018 are partial-data periods, so they should not be interpreted as full-month performance changes.
- São Paulo (SP) is the most important customer market by revenue and delivered order volume.
- `health_beauty` is the highest-revenue product category, while `bed_bath_table` leads in order volume.
- Credit card is the dominant payment method by delivered payment value.
- Customer satisfaction drops sharply as delivery lateness increases: orders delivered on time/early have the highest review score, while orders delivered 4+ days late have the lowest.
- High freight-share categories can be reviewed for shipping subsidies, packaging efficiency, seller allocation, or minimum-order thresholds.
- Retention is a major opportunity: the customer base is overwhelmingly one-time buyers.

## Recommendations

1. Prioritise late-delivery reduction for states with the longest average delivery duration.
2. Monitor categories with a high freight share before applying broad discount campaigns.
3. Use credit-card instalment offers and targeted post-purchase campaigns to convert one-time buyers.
4. Protect service quality in high-value markets such as SP, where operational issues can affect a large share of revenue.
5. Test bundles among frequently co-purchased categories to increase basket value.

## Data model

The MySQL database (`ecommerce_portfolio`) contains the following imported Olist tables:

- `customers`
- `orders`
- `order_items`
- `order_payments`
- `order_reviews`
- `products`
- `sellers`
- `category_translation`

A MySQL view, `vw_order_summary`, aggregates item, payment, and review information to the order level. This prevents duplicated revenue when analysing tables with one-to-many relationships.

## Workflow

1. Imported and validated CSV files in MySQL.
2. Created relational tables and foreign-key relationships.
3. Built SQL analyses using joins, aggregations, CTEs/window functions, and order-level safeguards.
4. Connected MySQL to Power BI Desktop.
5. Built a calendar table, delivery measures, and interactive date filtering.
6. Designed a two-page dashboard focused on commercial and operational decisions.

## Tools

- MySQL 8.0 and MySQL Workbench
- Power BI Desktop
- SQL
- DAX

## Project structure

```text
ecommerce-sales-customer-insights/
├── README.md
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_import_data.sql
│   ├── 03_create_order_summary_view.sql
│   └── 04_business_analysis.sql
├── dashboard/
│   └── Ecommers Visualization.pbix
└── images/
    ├── overview.png
    └── customer_operations.png
```

## Dataset

Brazilian E-Commerce Public Dataset by Olist (2016–2018), available on Kaggle: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

