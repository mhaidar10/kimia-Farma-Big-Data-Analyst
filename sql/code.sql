-- Mengambil dan aggregate data

/*
  ft = kf_final_transaction
  i  = kf_inventory
  kc = kf_kantor_cabang
  p  = kf_product
*/
CREATE TABLE kf_dataset.kf_analyst AS
SELECT 
    ft.transaction_id,  -- ID unik untuk setiap transaksi
    ft.date,  -- Tanggal transaksi
    ft.branch_id,  -- ID cabang tempat transaksi dilakukan
    kc.branch_name,  -- Nama cabang
    kc.kota,  -- Kota cabang
    kc.provinsi,  -- Provinsi cabang
    kc.rating AS rating_cabang,  -- Rating cabang berdasarkan kepuasan pelanggan
    ft.customer_name,  -- Nama customer yang melakukan transaksi
    ft.product_id,  -- ID produk yang dibeli
    p.product_name,  -- Nama produk yang dibeli
    p.price AS actual_price,  -- Harga asli produk
    ft.discount_percentage,  -- Persentase diskon yang diberikan pada produk



    -- Menentukan persentase laba berdasarkan harga produk
    CASE 
        WHEN p.price <= 50000 THEN 0.10                        -- Harga ≤ 50.000          → Laba 10%
        WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15   -- Harga 50.000 - 100.000  → Laba 15%
        WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20  -- Harga 100.000 - 300.000 → Laba 20%
        WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25  -- Harga 300.000 - 500.000 → Laba 25%
        ELSE 0.30                                              -- Harga > 500.000         → Laba 30%
    END AS persentase_gross_laba,


    -- Menghitung nett_sales (harga setelah diskon diterapkan)
    (p.price * (1 - ft.discount_percentage)) AS nett_sales,


    -- Menghitung nett_profit (keuntungan setelah diskon dan laba diterapkan)
    ((p.price * (1 - ft.discount_percentage)) * 
      CASE 
          WHEN p.price <= 50000 THEN 0.10
          WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
          WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
          WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
          ELSE 0.30
      END
    ) AS nett_profit,


    ft.rating AS rating_transaksi  -- Rating transaksi berdasarkan kepuasan pelanggan

-- Mengambil data dari tabel transaksi utama
FROM kf_dataset.kf_final_transaction AS ft

-- Menghubungkan dengan tabel kantor cabang berdasarkan branch_id
LEFT JOIN kf_dataset.kf_kantor_cabang AS kc 
    ON ft.branch_id = kc.branch_id

-- Menghubungkan dengan tabel produk berdasarkan product_id
LEFT JOIN kf_dataset.kf_product AS p 
    ON ft.product_id = p.product_id