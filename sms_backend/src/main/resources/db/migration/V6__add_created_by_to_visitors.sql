ALTER TABLE visitors
    ADD COLUMN created_by BIGINT NULL,
    ADD CONSTRAINT fk_visitors_created_by
        FOREIGN KEY (created_by) REFERENCES users(id)
        ON DELETE SET NULL;
