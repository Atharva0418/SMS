package com.atharvadholakia.sms_backend.controllers;

import com.atharvadholakia.sms_backend.models.Complaint;
import com.atharvadholakia.sms_backend.security.AuthUser;
import com.atharvadholakia.sms_backend.services.ComplaintService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/complaints")
@RequiredArgsConstructor
public class ComplaintController {

    private final ComplaintService complaintService;

    /** ADMIN — all; STAFF — own; RESIDENT — own. */
    @GetMapping
    public ResponseEntity<List<Complaint>> getAll(@AuthenticationPrincipal AuthUser principal) {
        return ResponseEntity.ok(complaintService.getAll(principal));
    }

    /** ADMIN + STAFF + RESIDENT. Tag is set server-side. */
    @PostMapping
    public ResponseEntity<Complaint> create(
            @RequestBody Complaint complaint,
            @AuthenticationPrincipal AuthUser principal) {
        Complaint saved = complaintService.create(complaint, principal);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    /** ADMIN (any, can resolve); RESIDENT (own, description only); STAFF — 403. */
    @PutMapping("/{id}")
    public ResponseEntity<Complaint> update(
            @PathVariable Long id,
            @RequestBody Complaint patch,
            @AuthenticationPrincipal AuthUser principal) {
        return ResponseEntity.ok(complaintService.update(id, patch, principal));
    }

    /** ADMIN (any); STAFF (own); RESIDENT — 403. */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable Long id,
            @AuthenticationPrincipal AuthUser principal) {
        complaintService.delete(id, principal);
        return ResponseEntity.noContent().build();
    }
}
