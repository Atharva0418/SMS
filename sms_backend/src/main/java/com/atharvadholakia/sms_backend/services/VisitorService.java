package com.atharvadholakia.sms_backend.services;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;

import com.atharvadholakia.sms_backend.models.Visitor;
import com.atharvadholakia.sms_backend.repositories.VisitorRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class VisitorService {

    private final VisitorRepository visitorRepository;

    public Visitor create(Visitor visitor) {
        visitor.setStatus("CHECKED_IN");
        visitor.setCheckInTime(LocalDateTime.now());
        return visitorRepository.save(visitor);
    }

    public List<Visitor> getAll() {
        return visitorRepository.findAll();
    }
}
