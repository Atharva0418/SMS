package com.atharvadholakia.sms_backend.services;

import com.atharvadholakia.sms_backend.models.User;
import com.atharvadholakia.sms_backend.models.Visitor;
import com.atharvadholakia.sms_backend.repositories.UserRepository;
import com.atharvadholakia.sms_backend.repositories.VisitorRepository;
import com.atharvadholakia.sms_backend.security.AuthUser;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class VisitorService {

    private final VisitorRepository visitorRepository;
    private final UserRepository    userRepository;

    /** Returns entries scoped to the caller's role. */
    public List<Visitor> getAll(AuthUser principal) {
        return switch (principal.role()) {
            case "ADMIN"    -> visitorRepository.findAll();
            case "STAFF"    -> visitorRepository.findByCreatedById(principal.id());
            case "RESIDENT" -> {
                User u = userRepository.findById(principal.id()).orElseThrow();
                yield visitorRepository.findByFlatNumberOrPhone(u.getFlatNumber(), u.getPhone());
            }
            default -> List.of();
        };
    }

    /** ADMIN + STAFF only (enforced at controller level via @PreAuthorize). */
    public Visitor create(Visitor visitor, Long creatorId) {
        if (visitor.getCheckInTime() == null) {
            visitor.setCheckInTime(LocalDateTime.now());
        }
        visitor.setStatus("CHECKED_IN");

        User creator = userRepository.findById(creatorId).orElse(null);
        visitor.setCreatedBy(creator);

        try {
            return visitorRepository.save(visitor);
        } catch (DataIntegrityViolationException ex) {
            return visitorRepository
                    .findByPhoneAndCheckInTime(visitor.getPhone(), visitor.getCheckInTime())
                    .orElseThrow(() -> ex);
        }
    }

    /** ADMIN can update any; STAFF only their own. */
    public Visitor update(Long id, Visitor patch, AuthUser principal) {
        Visitor existing = visitorRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Visitor not found"));

        if ("STAFF".equals(principal.role())) {
            if (existing.getCreatedBy() == null ||
                !existing.getCreatedBy().getId().equals(principal.id())) {
                throw new SecurityException("Not authorised to edit this entry");
            }
        }

        existing.setName(patch.getName());
        existing.setPhone(patch.getPhone());
        existing.setFlatNumber(patch.getFlatNumber());
        return visitorRepository.save(existing);
    }

    /** ADMIN only (enforced at controller level via @PreAuthorize). */
    public void delete(Long id) {
        visitorRepository.deleteById(id);
    }
}