package com.atharvadholakia.sms_backend.controllers;

import com.atharvadholakia.sms_backend.models.Complaint;
import com.atharvadholakia.sms_backend.services.ComplaintService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/complaints")
@RequiredArgsConstructor
public class ComplaintController {

    private final ComplaintService complaintService;

    @PostMapping
    public ResponseEntity<Complaint> create(
            @RequestBody Complaint complaint) {
        Complaint saved = complaintService.create(complaint);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping
    public ResponseEntity<List<Complaint>> getAll() {
        return ResponseEntity.ok(complaintService.getAll());
    }
}
