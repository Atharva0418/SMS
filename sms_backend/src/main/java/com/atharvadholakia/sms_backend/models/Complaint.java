package com.atharvadholakia.sms_backend.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "complaints")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Complaint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "flat_number", nullable = false)
    private Integer flatNumber;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 20)
    private String status;

    // "STAFF" or "RESIDENT" — set server-side from JWT role
    @Column(nullable = false, length = 20)
    private String tag;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // Lazy-loaded — Jackson must never touch this outside a Hibernate session.
    // The Flutter client does not need createdBy; ownership is enforced server-side.
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;
}