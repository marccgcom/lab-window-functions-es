# 1. Calcular la duración media del alquiler (en días) para cada película:
SELECT
    title,
    rental_duration,
    AVG(rental_duration) OVER () AS avg_rental_duration
FROM
    film;
    
# 2. Calcular el importe medio de los pagos para cada miembro del personal:
SELECT
    staff_id,
    AVG(amount) OVER (PARTITION BY staff_id) AS avg_payment_amount
FROM
    payment;

# 3. Calcular los ingresos totales para cada cliente, mostrando el total acumulado 
# dentro del historial de alquileres de cada cliente:
SELECT
    payment.customer_id,
    rental_id,
    rental_date,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id ORDER BY rental_date) AS running_total
FROM
    payment
    JOIN rental USING (rental_id)
ORDER BY
    customer_id, rental_date;
    
# 4. Determinar el cuartil para las tarifas de alquiler de las películas
SELECT
    title,
    rental_rate,
    NTILE(4) OVER (ORDER BY rental_rate) AS quartile
FROM
    film;
    
# 5. Determinar la primera y última fecha de alquiler para cada cliente:
SELECT
    customer_id,
    MIN(rental_date) OVER (PARTITION BY customer_id) AS first_rental_date,
    MAX(rental_date) OVER (PARTITION BY customer_id) AS last_rental_date
FROM
    rental;
    
# 6. Calcular el rango de los clientes basado en el número de sus alquileres:
SELECT
    customer_id,
    rental_count,
    RANK() OVER (ORDER BY rental_count DESC) AS rental_count_rank
FROM (
    SELECT
        customer_id,
        COUNT(rental_id) AS rental_count
    FROM
        rental
    GROUP BY
        customer_id
) AS rental_counts;

# 7. Calcular el total acumulado de ingresos por día para la categoría de películas 'Familiar':
SELECT
    film_category,
    rental_date,
    amount,
    SUM(amount) OVER (PARTITION BY rental_date ORDER BY rental_date) AS daily_revenue
FROM (
    SELECT
        f.title AS film_category,
        r.rental_date,
        p.amount
    FROM
        film AS f
        JOIN inventory AS i ON f.film_id = i.film_id
        JOIN rental AS r ON i.inventory_id = r.inventory_id
        JOIN payment AS p ON r.rental_id = p.rental_id
    WHERE
        f.rating = 'G'
) AS daily_revenue;

# 8. Asignar un ID único a cada pago dentro del historial de pagos de cada cliente:
SELECT
    customer_id,
    payment_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_sequence_id
FROM
    payment;
    
# 9. Calcular la diferencia en días entre cada alquiler y el alquiler anterior para cada cliente:
SELECT
    customer_id,
    rental_id,
    rental_date,
    LAG(rental_date) OVER (PARTITION BY customer_id ORDER BY rental_date) AS previous_rental_date,
    DATEDIFF(rental_date, LAG(rental_date) OVER (PARTITION BY customer_id ORDER BY rental_date)) AS days_between_rentals
FROM
    rental
ORDER BY
    customer_id, rental_date;
    
