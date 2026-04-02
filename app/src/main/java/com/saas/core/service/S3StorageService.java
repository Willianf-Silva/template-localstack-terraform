package com.saas.core.service;

import io.awspring.cloud.s3.S3Template;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.UUID;

@Service
public class S3StorageService {
    private final S3Template s3Template;
    private final String bucketName;

    public S3StorageService(S3Template s3Template, @Value("${app.aws.s3.bucket-name}") String bucketName) {
        this.s3Template = s3Template;
        this.bucketName = bucketName;
    }

    public String uploadFile(MultipartFile file) {
        try {
            String uniqueFileName = UUID.randomUUID() + "-" + file.getOriginalFilename();
            s3Template.upload(bucketName, uniqueFileName, file.getInputStream());
            return uniqueFileName;
        } catch (IOException e) {
            throw new RuntimeException("Falha ao enviar arquivo para o S3 Local", e);
        }
    }
}