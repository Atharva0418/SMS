package com.atharvadholakia.sms_backend.repositories;

import com.atharvadholakia.sms_backend.models.Complaint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, Long> {

    List<Complaint> findByCreatedById(Long userId);
}
