package com.atharvadholakia.sms_backend.controllers;

import com.atharvadholakia.sms_backend.dtos.AuthDtos.NoticeRequest;
import com.atharvadholakia.sms_backend.models.Notice;
import com.atharvadholakia.sms_backend.security.AuthUser;
import com.atharvadholakia.sms_backend.services.NoticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notices")
@RequiredArgsConstructor
public class NoticeController {

    private final NoticeService noticeService;

    /** All authenticated roles. */
    @GetMapping
    public ResponseEntity<List<Notice>> getAll() {
        return ResponseEntity.ok(noticeService.getAll());
    }

    /** ADMIN only. */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Notice> create(
            @RequestBody NoticeRequest req,
            @AuthenticationPrincipal AuthUser principal) {
        Notice saved = noticeService.create(req, principal.id());
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    /** ADMIN only. */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Notice> update(
            @PathVariable Long id,
            @RequestBody NoticeRequest req) {
        return ResponseEntity.ok(noticeService.update(id, req));
    }

    /** ADMIN only. */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        noticeService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
