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

    // RESIDENT: filter by flat number or phone
    List<Visitor> findByFlatNumberOrPhone(Integer flatNumber, String phone);

    // STAFF: only entries they created
    List<Visitor> findByCreatedById(Long userId);
}
