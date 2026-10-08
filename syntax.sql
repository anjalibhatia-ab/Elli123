DECLARE
    v_name VARCHAR2(50);
    v_age NUMBER;
BEGIN
    v_name := 'John'
    v_age := 25;

    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('Age: ' || v_age)

    IF v_age >= 18 THEN
        DBMS_OUTPUT.PUT_LINE('Adult');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Minor');
    END IF
END;
/
