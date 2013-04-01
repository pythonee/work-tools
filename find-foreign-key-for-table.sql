SELECT
    CONCAT(table_name, '.', column_name) AS 'foreign key',  
    CONCAT(referenced_table_name, '.', referenced_column_name) AS 'references',
    CONCAT( table_name, '.', column_name, ' -> ', referenced_table_name, '.', referenced_column_name ) AS relationship
FROM
    information_schema.key_column_usage 
WHERE
    referenced_table_name = 'vm_instance' AND table_schema = 'cloud'
ORDER BY
    constraint_schema, table_name, column_name;

