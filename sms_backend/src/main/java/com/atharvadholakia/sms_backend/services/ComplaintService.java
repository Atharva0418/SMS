package com.atharvadholakia.sms_backend.services;

import com.atharvadholakia.sms_backend.models.Complaint;
import com.atharvadholakia.sms_backend.models.User;
import com.atharvadholakia.sms_backend.repositories.ComplaintRepository;
import com.atharvadholakia.sms_backend.repositories.UserRepository;
import com.atharvadholakia.sms_backend.security.AuthUser;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ComplaintService {

    private final ComplaintRepository complaintRepository;
    private final UserRepository      userRepository;

    /** All authenticated users see all complaints. */
    public List<Complaint> getAll(AuthUser principal) {
        return complaintRepository.findAll();
    }

    /** Tag is set server-side from the JWT role — client cannot override it. */
    public Complaint create(Complaint complaint, AuthUser principal) {
        complaint.setStatus("OPEN");
        complaint.setTag(principal.role()); // "STAFF" or "RESIDENT"
        complaint.setCreatedAt(LocalDateTime.now());

        User creator = userRepository.findById(principal.id()).orElse(null);
        complaint.setCreatedBy(creator);

        return complaintRepository.save(complaint);
    }

    /**
     * Permission rules:
     *  ADMIN    — any field, can set status to RESOLVED
     *  RESIDENT — own complaints, description only (cannot change status)
     *  STAFF    — cannot edit
     */
    public Complaint update(Long id, Complaint patch, AuthUser principal) {
        Complaint existing = complaintRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Complaint not found"));

        switch (principal.role()) {
            case "ADMIN" -> {
                existing.setDescription(patch.getDescription());
                if (patch.getStatus() != null) existing.setStatus(patch.getStatus());
            }
            case "RESIDENT" -> {
                if (existing.getCreatedBy() == null ||
                    !existing.getCreatedBy().getId().equals(principal.id())) {
                    throw new SecurityException("Not authorised");
                }
                existing.setDescription(patch.getDescription());
            }
            default -> throw new SecurityException("STAFF cannot edit complaints");
        }

        return complaintRepository.save(existing);
    }

    /**
     * ADMIN: any complaint.
     * STAFF: own complaints only.
     * RESIDENT: cannot delete.
     */
    public void delete(Long id, AuthUser principal) {
        Complaint existing = complaintRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Complaint not found"));

        if ("RESIDENT".equals(principal.role())) {
            throw new SecurityException("Residents cannot delete complaints");
        }
        if ("STAFF".equals(principal.role())) {
            if (existing.getCreatedBy() == null ||
                !existing.getCreatedBy().getId().equals(principal.id())) {
                throw new SecurityException("STAFF can only delete their own complaints");
            }
        }

        complaintRepository.deleteById(id);
    }
}