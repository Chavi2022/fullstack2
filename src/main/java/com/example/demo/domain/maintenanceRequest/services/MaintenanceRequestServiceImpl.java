package com.example.demo.domain.maintenanceRequest.services;

import com.example.demo.domain.core.exceptions.ResourceFoundException;
import com.example.demo.domain.core.exceptions.ResourceNotFoundException;
import com.example.demo.domain.maintenanceRequest.model.MaintenanceRequest;
import com.example.demo.domain.maintenanceRequest.repos.MaintenanceRequestRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class MaintenanceRequestServiceImpl implements MaintenanceRequestService{
    private final MaintenanceRequestRepo maintenanceRequestRepo;

    @Autowired
    public MaintenanceRequestServiceImpl(MaintenanceRequestRepo maintenanceRequestRepo) {
        this.maintenanceRequestRepo = maintenanceRequestRepo;
    }

    @Override
    public MaintenanceRequest create(MaintenanceRequest request) throws ResourceFoundException {
        Optional<MaintenanceRequest> optional = maintenanceRequestRepo.findByEmail(request.getEmail());
        if (optional.isPresent()) {
            throw new ResourceFoundException("Request with this email already exists: " + request.getEmail());
        }
        request.setCreatedAt(LocalDateTime.now().toString());
        return maintenanceRequestRepo.save(request);
    }

    @Override
    public MaintenanceRequest getById(Long id) throws ResourceNotFoundException {
        return maintenanceRequestRepo.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("No request found with id: " + id));
    }

    @Override
    public MaintenanceRequest getByEmail(String email) throws ResourceNotFoundException {
        return maintenanceRequestRepo.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("No request found with email: " + email));
    }

    @Override
    public List<MaintenanceRequest> getAll() {
        return maintenanceRequestRepo.findAll();
    }

    @Override
    public MaintenanceRequest update(Long id, MaintenanceRequest requestDetails) throws ResourceNotFoundException {
        MaintenanceRequest request = getById(id);
        request.setFirstName(requestDetails.getFirstName());
        request.setLastName(requestDetails.getLastName());
        request.setEmail(requestDetails.getEmail());
        request.setAptNum(requestDetails.getAptNum());
        request.setDescription(requestDetails.getDescription());
        request.setCreatedAt(requestDetails.getCreatedAt());
        return maintenanceRequestRepo.save(request);
    }

    @Override
    public void delete(Long id) throws ResourceNotFoundException {
        MaintenanceRequest request = getById(id);
        maintenanceRequestRepo.delete(request);
    }
}