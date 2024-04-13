-- Create a sequence for table_id specific to each branch
CREATE OR REPLACE FUNCTION create_branch_table_sequence() RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM pg_sequences WHERE sequencename = 'branch_' || NEW.branch_id || '_table_id_seq') THEN
        EXECUTE 'CREATE SEQUENCE branch_' || NEW.branch_id || '_table_id_seq';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_branch_table_sequence_trigger
AFTER INSERT ON branches
FOR EACH ROW EXECUTE FUNCTION create_branch_table_sequence();

