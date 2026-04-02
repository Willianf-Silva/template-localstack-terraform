package com.saas.core.controller;

import com.saas.core.service.S3StorageService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/files")
public class FileUploadController {
    private final S3StorageService s3StorageService;

    public FileUploadController(S3StorageService s3StorageService) {
        this.s3StorageService = s3StorageService;
    }

    @PostMapping("/upload")
    public ResponseEntity<String> upload(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Arquivo não pode ser vazio!");
        }
        String savedFileName = s3StorageService.uploadFile(file);
        return ResponseEntity.ok("Sucesso! Arquivo salvo como: " + savedFileName);
    }
}