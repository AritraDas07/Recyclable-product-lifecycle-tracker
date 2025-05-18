module RecycleLabs::ProductTracker {
    use aptos_framework::account;
    use std::signer;
    use std::string::String;
    use aptos_framework::event;
    use aptos_std::table::{Self, Table};
    
    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_PRODUCT_NOT_FOUND: u64 = 2;
    const E_ALREADY_REGISTERED: u64 = 3;
    
    /// Product lifecycle statuses
    const STATUS_PRODUCED: u64 = 1;
    const STATUS_SOLD: u64 = 2;
    const STATUS_RETURNED: u64 = 3;
    const STATUS_RECYCLED: u64 = 4;
    
    /// Struct representing a recyclable product
    struct Product has store, drop {
        product_type: String,
        status: u64,
        manufacturer: address,
        recycled_count: u64,
    }
    
    /// Resource that stores the product registry
    struct ProductRegistry has key {
        products: Table<String, Product>,
        product_status_events: event::EventHandle<ProductStatusEvent>,
    }
    
    /// Event emitted when a product status changes
    struct ProductStatusEvent has drop, store {
        product_id: String,
        old_status: u64,
        new_status: u64,
    }
    
    /// Initialize a new product registry for the account
    public entry fun initialize_registry(account: &signer) {
        let addr = signer::address_of(account);
        if (!exists<ProductRegistry>(addr)) {
            move_to(account, ProductRegistry {
                products: table::new(),
                product_status_events: account::new_event_handle<ProductStatusEvent>(account),
            });
        }
    }
    
    /// Register a new product in the registry
    public entry fun register_product(
        account: &signer, 
        product_id: String,
        product_type: String
    ) acquires ProductRegistry {
        let addr = signer::address_of(account);
        assert!(exists<ProductRegistry>(addr), E_NOT_AUTHORIZED);
        
        let registry = borrow_global_mut<ProductRegistry>(addr);
        assert!(!table::contains(&registry.products, product_id), E_ALREADY_REGISTERED);
        
        let product = Product {
            product_type,
            status: STATUS_PRODUCED,
            manufacturer: addr,
            recycled_count: 0,
        };
        
        table::add(&mut registry.products, product_id, product);
    }
    
    /// Update the status of a product in the lifecycle
    public entry fun update_product_status(
        account: &signer,
        product_id: String,
        new_status: u64
    ) acquires ProductRegistry {
        let addr = signer::address_of(account);
        assert!(exists<ProductRegistry>(addr), E_NOT_AUTHORIZED);
        
        let registry = borrow_global_mut<ProductRegistry>(addr);
        assert!(table::contains(&registry.products, product_id), E_PRODUCT_NOT_FOUND);
        
        let product = table::borrow_mut(&mut registry.products, product_id);
        let old_status = product.status;
        product.status = new_status;
        
        // Increment recycled count if product is being recycled
        if (new_status == STATUS_RECYCLED) {
            product.recycled_count = product.recycled_count + 1;
        }
        
        // Emit event for product status change
        event::emit_event(&mut registry.product_status_events, ProductStatusEvent {
            product_id,
            old_status,
            new_status,
        });
    }
}