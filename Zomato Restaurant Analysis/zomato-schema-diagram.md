# Zomato Database Schema Diagram

## Table Relationships

```
┌─────────────────────────────────┐         ┌────────────────────────────────────────────────────────────┐
│         COUNTRY_CODE            │         │                    ZOMATO_DATASET                          │
├─────────────────────────────────┤         ├────────────────────────────────────────────────────────────┤
│ Country Code (PK) │ INT         │◄────────┤ CountryCode (FK)        │ INT                              │
│ Country           │ VARCHAR(50) │         │ RestaurantID (PK)       │ INT                              │
└─────────────────────────────────┘         │ RestaurantName          │ VARCHAR(255)                     │
                                            │ City                    │ VARCHAR(100)                     │
                                            │ Address                 │ TEXT                             │
                                            │ Locality                │ TEXT                             │
                                            │ LocalityVerbose         │ TEXT                             │
                                            │ Cuisines                │ VARCHAR(255)                     │
                                            │ Currency                │ VARCHAR(50)                      │
                                            │ Has_Table_booking       │ VARCHAR(5)                       │
                                            │ Has_Online_delivery     │ VARCHAR(5)                       │
                                            │ Is_delivering_now       │ VARCHAR(5)                       │
                                            │ Switch_to_order_menu    │ VARCHAR(5)                       │
                                            │ Price_range             │ INT                              │
                                            │ Votes                   │ INT                              │
                                            │ Average_Cost_for_two    │ INT                              │
                                            │ Rating                  │ DECIMAL(2,1)                     │
                                            └────────────────────────────────────────────────────────────┘
```