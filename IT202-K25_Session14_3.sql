USE RikkeiClinicDB;

delimiter //

create procedure dispensedrugs(
    in p_patient_id int,
    in p_medicine_id int,
    in p_quantity int,
    out p_message varchar(255)
)
begin
    declare v_price decimal(18,2);
    declare v_total_cost decimal(18,2);
    declare v_stock_after int;

    start transaction;

    select price into v_price from medicines where medicine_id = p_medicine_id;

    update medicines 
    set stock = stock - p_quantity 
    where medicine_id = p_medicine_id;

    set v_total_cost = p_quantity * v_price;
    update patient_invoices 
    set total_due = total_due + v_total_cost 
    where patient_id = p_patient_id;

    select stock into v_stock_after from medicines where medicine_id = p_medicine_id;

    if v_stock_after < 0 then
        rollback;
        set p_message = 'lỗi: số lượng tồn kho không đủ';
    else
        commit;
        set p_message = 'đã cấp phát thành công';
    end if;
end //

delimiter ;
