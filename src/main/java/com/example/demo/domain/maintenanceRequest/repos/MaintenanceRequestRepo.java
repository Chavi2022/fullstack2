package com.example.demo.domain.maintenanceRequest.repos;

import com.example.demo.domain.maintenanceRequest.model.MaintenanceRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MaintenanceRequestRepo extends JpaRepository<MaintenanceRequest, Long> {
    Optional<MaintenanceRequest> findByEmail(String email);
}






