package com.atharvadholakia.sms_backend.repositories;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.atharvadholakia.sms_backend.models.Visitor;

@Repository
public interface VisitorRepository extends JpaRepository<Visitor, Long> {

    /**
     * Used by {@link com.atharvadholakia.sms_backend.services.VisitorService}
     * to look up an existing record when a duplicate-sync retry is detected.
     */
    Optional<Visitor> findByPhoneAndCheckInTime(String phone, LocalDateTime checkInTime);
}