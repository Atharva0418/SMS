package com.atharvadholakia.sms_backend.controllers;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.atharvadholakia.sms_backend.models.Visitor;
import com.atharvadholakia.sms_backend.services.VisitorService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/visitors")
@RequiredArgsConstructor
public class VisitorController {

    private final VisitorService visitorService;

    @PostMapping
    public ResponseEntity<Visitor> create(
            @RequestBody Visitor visitor) {
        Visitor saved = visitorService.create(visitor);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping
    public ResponseEntity<List<Visitor>> getAll() {
        return ResponseEntity.ok(visitorService.getAll());
    }
}