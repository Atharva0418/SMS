package com.atharvadholakia.sms_backend.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "visitors",
    uniqueConstraints = {
        @UniqueConstraint(
            name = "uq_visitors_phone_checkin",
            columnNames = {"phone", "check_in_time"}
        )
    }
)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Visitor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 15)
    private String phone;

    @Column(name = "flat_number", nullable = false)
    private Integer flatNumber;

    @Column(name = "check_in_time")
    private LocalDateTime checkInTime;

    @Column(name = "check_out_time")
    private LocalDateTime checkOutTime;

    @Column(nullable = false, length = 20)
    private String status;

    // Lazy-loaded — Jackson must never touch this outside a Hibernate session.
    // The Flutter client does not need createdBy; it only needs the scalar fields above.
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;
}