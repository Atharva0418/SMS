package com.atharvadholakia.sms_backend.services;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import com.atharvadholakia.sms_backend.models.Visitor;
import com.atharvadholakia.sms_backend.repositories.VisitorRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class VisitorService {

    private final VisitorRepository visitorRepository;

    /**
     * Persists a new visitor entry.
     *
     * <p>The client sends {@code checkInTime} from its local clock so that the
     * stored timestamp reflects when the visitor actually arrived, not when the
     * device regained connectivity and synced the record. If the field is absent
     * (older clients / manual API calls) we fall back to the server time.
     *
     * <p>If an identical {@code (phone, checkInTime)} record already exists
     * (duplicate sync retry) we return the existing row instead of inserting a
     * second one, satisfying the "no duplicate records" acceptance criterion.
     */
    public Visitor create(Visitor visitor) {
        if (visitor.getCheckInTime() == null) {
            visitor.setCheckInTime(LocalDateTime.now());
        }
        visitor.setStatus("CHECKED_IN");

        try {
            return visitorRepository.save(visitor);
        } catch (DataIntegrityViolationException ex) {
            // (phone, check_in_time) unique constraint violated — this is a
            // retry of an already-synced entry.  Return the existing record.
            return visitorRepository
                    .findByPhoneAndCheckInTime(visitor.getPhone(), visitor.getCheckInTime())
                    .orElseThrow(() -> ex);
        }
    }

    public List<Visitor> getAll() {
        return visitorRepository.findAll();
    }
}