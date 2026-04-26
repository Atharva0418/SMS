package com.atharvadholakia.sms_backend.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.atharvadholakia.sms_backend.dtos.AuthDtos.AuthResponse;
import com.atharvadholakia.sms_backend.dtos.AuthDtos.LoginRequest;
import com.atharvadholakia.sms_backend.dtos.AuthDtos.RegisterRequest;
import com.atharvadholakia.sms_backend.services.AuthService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /** Creates a user with status PENDING — admin must approve before login works. */
    @PostMapping("/register")
    public ResponseEntity<Void> register(@RequestBody RegisterRequest req) {
        authService.register(req);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    /** Returns a signed JWT only if the account is APPROVED. */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest req) {
        return ResponseEntity.ok(authService.login(req));
    }
}
