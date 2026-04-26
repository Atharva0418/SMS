ALTER TABLE complaints
    ADD COLUMN tag        VARCHAR(20) NOT NULL DEFAULT 'RESIDENT' AFTER status,
    ADD COLUMN created_by BIGINT      NULL,
    ADD CONSTRAINT fk_complaints_created_by
        FOREIGN KEY (created_by) REFERENCES users(id)
        ON DELETE SET NULL;
