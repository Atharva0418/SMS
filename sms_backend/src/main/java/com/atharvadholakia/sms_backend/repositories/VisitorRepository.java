package com.atharvadholakia.sms_backend.repositories;

import com.atharvadholakia.sms_backend.models.Visitor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface VisitorRepository extends JpaRepository<Visitor, Long> {

    Optional<Visitor> findByPhoneAndCheckInTime(String phone, LocalDateTime checkInTime);

    // RESIDENT: only visitors destined for their flat
    List<Visitor> findByFlatNumber(Integer flatNumber);

    // STAFF: kept for potential future use (e.g. per-staff activity report)
    List<Visitor> findByCreatedById(Long userId);
}
