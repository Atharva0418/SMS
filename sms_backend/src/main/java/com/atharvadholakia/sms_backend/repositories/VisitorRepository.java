package com.atharvadholakia.sms_backend.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.atharvadholakia.sms_backend.models.Visitor;

@Repository
public interface VisitorRepository
        extends JpaRepository<Visitor, Long> {
}