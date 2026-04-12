CREATE TABLE sync_logs (
    id          BIGINT      NOT NULL AUTO_INCREMENT,
    entity_type VARCHAR(50) NOT NULL,
    entity_id   BIGINT      NOT NULL,
    operation   VARCHAR(20) NOT NULL,
    sync_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;