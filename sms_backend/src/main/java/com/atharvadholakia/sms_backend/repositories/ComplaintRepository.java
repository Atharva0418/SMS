package com.atharvadholakia.sms_backend.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.atharvadholakia.sms_backend.models.Complaint;

@Repository
public interface ComplaintRepository
        extends JpaRepository<Complaint, Long> {
}