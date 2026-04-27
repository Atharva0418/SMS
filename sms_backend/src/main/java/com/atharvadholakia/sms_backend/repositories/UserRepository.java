package com.atharvadholakia.sms_backend.repositories;

import com.atharvadholakia.sms_backend.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);

    /** Used by UserService to fetch the admin approval queue. */
    List<User> findByStatus(User.Status status);
}
