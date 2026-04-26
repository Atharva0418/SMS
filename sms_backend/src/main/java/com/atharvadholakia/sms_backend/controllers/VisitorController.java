package com.atharvadholakia.sms_backend.controllers;

import com.atharvadholakia.sms_backend.models.Visitor;
import com.atharvadholakia.sms_backend.security.AuthUser;
import com.atharvadholakia.sms_backend.services.VisitorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/visitors")
@RequiredArgsConstructor
public class VisitorController {

    private final VisitorService visitorService;

    /** ADMIN — all entries; STAFF — own entries; RESIDENT — own flat/phone entries. */
    @GetMapping
    public ResponseEntity<List<Visitor>> getAll(@AuthenticationPrincipal AuthUser principal) {
        return ResponseEntity.ok(visitorService.getAll(principal));
    }

    /** ADMIN + STAFF only. */
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'STAFF')")
    public ResponseEntity<Visitor> create(
            @RequestBody Visitor visitor,
            @AuthenticationPrincipal AuthUser principal) {
        Visitor saved = visitorService.create(visitor, principal.id());
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    /** ADMIN (any), STAFF (own only). */
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'STAFF')")
    public ResponseEntity<Visitor> update(
            @PathVariable Long id,
            @RequestBody Visitor patch,
            @AuthenticationPrincipal AuthUser principal) {
        return ResponseEntity.ok(visitorService.update(id, patch, principal));
    }

    /** ADMIN only. */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        visitorService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
