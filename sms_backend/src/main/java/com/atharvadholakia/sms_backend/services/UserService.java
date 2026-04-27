package com.atharvadholakia.sms_backend.services;

import com.atharvadholakia.sms_backend.models.User;
import com.atharvadholakia.sms_backend.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    /** Returns all users with PENDING status — shown in the admin approval queue. */
    public List<User> getPendingUsers() {
        return userRepository.findByStatus(User.Status.PENDING);
    }

    /** Returns all users regardless of status — for a full user-management view. */
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public User approve(Long userId) {
        return updateStatus(userId, User.Status.APPROVED);
    }

    public User reject(Long userId) {
        return updateStatus(userId, User.Status.REJECTED);
    }

    private User updateStatus(Long userId, User.Status newStatus) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        user.setStatus(newStatus);
        return userRepository.save(user);
    }
}
