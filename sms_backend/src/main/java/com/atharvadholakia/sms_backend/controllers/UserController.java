package com.atharvadholakia.sms_backend.controllers;

import com.atharvadholakia.sms_backend.models.User;
import com.atharvadholakia.sms_backend.services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")   // every endpoint here is ADMIN-only
public class UserController {

    private final UserService userService;

    /**
     * Returns all users with status=PENDING.
     * Used to populate the admin approval queue.
     */
    @GetMapping("/pending")
    public ResponseEntity<List<User>> getPending() {
        return ResponseEntity.ok(userService.getPendingUsers());
    }

    /**
     * Returns all users (any status).
     * Useful for a full user-management panel in future.
     */
    @GetMapping
    public ResponseEntity<List<User>> getAll() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    /** Approve a pending registration. */
    @PatchMapping("/{id}/approve")
    public ResponseEntity<User> approve(@PathVariable Long id) {
        return ResponseEntity.ok(userService.approve(id));
    }

    /** Reject a pending registration. */
    @PatchMapping("/{id}/reject")
    public ResponseEntity<User> reject(@PathVariable Long id) {
        return ResponseEntity.ok(userService.reject(id));
    }
}
