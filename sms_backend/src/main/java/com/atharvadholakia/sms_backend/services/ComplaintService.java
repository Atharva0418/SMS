package com.atharvadholakia.sms_backend.services;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;

import com.atharvadholakia.sms_backend.models.Complaint;
import com.atharvadholakia.sms_backend.repositories.ComplaintRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComplaintService {

    private final ComplaintRepository complaintRepository;

    public Complaint create(Complaint complaint) {
        complaint.setStatus("OPEN");
        complaint.setCreatedAt(LocalDateTime.now());
        return complaintRepository.save(complaint);
    }

    public List<Complaint> getAll() {
        return complaintRepository.findAll();
    }
}