package com.atharvadholakia.sms_backend.services;

import com.atharvadholakia.sms_backend.dtos.AuthDtos.NoticeRequest;
import com.atharvadholakia.sms_backend.models.Notice;
import com.atharvadholakia.sms_backend.models.User;
import com.atharvadholakia.sms_backend.repositories.NoticeRepository;
import com.atharvadholakia.sms_backend.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NoticeService {

    private final NoticeRepository noticeRepository;
    private final UserRepository   userRepository;

    public Notice create(NoticeRequest req, Long adminId) {
        User admin = userRepository.findById(adminId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Notice notice = Notice.builder()
                .title(req.title())
                .body(req.body())
                .createdBy(admin)
                .createdAt(LocalDateTime.now())
                .build();

        return noticeRepository.save(notice);
    }

    public List<Notice> getAll() {
        return noticeRepository.findAll();
    }

    public Notice update(Long id, NoticeRequest req) {
        Notice notice = noticeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Notice not found"));
        notice.setTitle(req.title());
        notice.setBody(req.body());
        return noticeRepository.save(notice);
    }

    public void delete(Long id) {
        noticeRepository.deleteById(id);
    }
}
