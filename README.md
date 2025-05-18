# RecycleLabs ProductTracker

A blockchain-based solution for transparent tracking of recyclable products throughout their entire lifecycle.

## Overview

`ProductTracker` is a Move smart contract built for the Aptos blockchain that enables manufacturers to register recyclable products and track their journey from production to recycling. The contract provides a transparent, immutable record of each product's lifecycle, helping to improve sustainability efforts and verify recycling claims.

## Features

- **Secure Product Registration**: Manufacturers can register products with unique IDs
- **Lifecycle Status Tracking**: Products progress through defined lifecycle stages
- **Recycling Counter**: Automatically tracks how many times a product has been recycled
- **Event Emission**: All status changes generate blockchain events for auditability
- **Permission Controls**: Only authorized accounts can modify product status

## Lifecycle Statuses

Products in the system can have the following statuses:

1. `STATUS_PRODUCED (1)`: Product has been manufactured
2. `STATUS_SOLD (2)`: Product has been sold to a consumer
3. `STATUS_RETURNED (3)`: Product has been returned for recycling
4. `STATUS_RECYCLED (4)`: Product has been processed for recycling

## Smart Contract Details

- **Module Path**: `RecycleLabs::ProductTracker`
- **File**: `ProductTracker.move`
- **Target Blockchain**: Aptos

## Usage

### Prerequisites

- Aptos CLI installed
- Account with APT for transaction fees

### Initialization

Before registering products, a manufacturer must initialize their product registry:

```bash
aptos move run --function-id 0x<YOUR_ADDRESS>::ProductTracker::initialize_registry
```

### Registering Products
```bash
aptos move run --function-id 0x<YOUR_ADDRESS>::ProductTracker::register_product \
  --args string:"PROD123" string:"RecyclablePlastic"
```

### Updating Product Status
```bash
aptos move run --function-id 0x<YOUR_ADDRESS>::ProductTracker::update_product_status \
  --args string:"PROD123" u64:3
```
### Integration Ideas

- Consumer App: Scan product QR codes to verify authenticity and view lifecycle
- Recycling Centers: Update product status upon receipt and processing
- Sustainability Reporting: Generate reports on recycling rates for different products
- Supply Chain Integration: Connect with existing supply chain tracking systems

### Technical Architecture
The contract uses Aptos's Table data structure to efficiently store and retrieve product information by ID. Event emission allows off-chain applications to track status changes in real-time.

```bash
┌─────────────────┐     ┌───────────────────┐     ┌─────────────────┐
│  Manufacturer   │     │      Product      │     │ Status Updates  │
│  (Account)      │◄────┤    Registry       │◄────┤ (Events)        │
└─────────────────┘     └───────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌───────────────────┐
                        │ Product Entries   │
                        │ - ID             │
                        │ - Type           │
                        │ - Status         │
                        │ - Recycled Count │
                        └───────────────────┘
```

### Best Practices

- Always verify product existence before updating status
- Use unique and meaningful product IDs
- Monitor events for real-time tracking
- Consider implementing additional verification checks for status transition
