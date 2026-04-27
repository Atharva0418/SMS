package com.atharvadholakia.sms_backend.dtos;

// ── Register ──────────────────────────────────────────────────────────────────

public class AuthDtos {

    public record RegisterRequest(
        String name,
        String email,
        String password,
        String role,       // "STAFF" or "RESIDENT"
        Integer flatNumber // required only for RESIDENT
    ) {}

    public record LoginRequest(
        String email,
        String password
    ) {}

    public record AuthResponse(
        String  token,
        String  role,
        String  name,
        Long    userId,
        Integer flatNumber  // null for ADMIN and STAFF
    ) {}

    public record NoticeRequest(
        String title,
        String body
    ) {}
}
