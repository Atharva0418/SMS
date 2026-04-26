ALTER TABLE visitors
    ADD CONSTRAINT uq_visitors_phone_checkin
    UNIQUE (phone, check_in_time);