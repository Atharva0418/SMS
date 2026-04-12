CREATE TABLE visitors (
    id             BIGINT       NOT NULL AUTO_INCREMENT,
    name           VARCHAR(100) NOT NULL,
    phone          VARCHAR(15)  NOT NULL,
    flat_number    INT          NOT NULL,
    check_in_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    check_out_time DATETIME     NULL,
    status         VARCHAR(20)  NOT NULL DEFAULT 'CHECKED_IN',
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;