CREATE TABLE complaints (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    flat_number INT          NOT NULL,
    description TEXT         NOT NULL,
    status      VARCHAR(20)  NOT NULL DEFAULT 'OPEN',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;