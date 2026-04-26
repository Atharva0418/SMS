package com.atharvadholakia.sms_backend.security;

/**
 * Lightweight principal placed into the SecurityContext after JWT validation.
 * Accessible in controllers via {@code @AuthenticationPrincipal AuthUser user}.
 */
public record AuthUser(Long id, String email, String role) {}
