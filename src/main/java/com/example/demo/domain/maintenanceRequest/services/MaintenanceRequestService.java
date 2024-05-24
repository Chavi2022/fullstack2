package com.example.demo.domain.maintenanceRequest.services;


import com.example.demo.domain.core.exceptions.ResourceFoundException;
import com.example.demo.domain.core.exceptions.ResourceNotFoundException;
import com.example.demo.domain.maintenanceRequest.model.MaintenanceRequest;

import java.util.List;

public interface MaintenanceRequestService {
    MaintenanceRequest create(MaintenanceRequest request) throws ResourceFoundException;
    MaintenanceRequest getById(Long id) throws ResourceNotFoundException;
    MaintenanceRequest getByEmail(String email) throws ResourceNotFoundException;
    List<MaintenanceRequest> getAll();
    MaintenanceRequest update(Long id, MaintenanceRequest requestDetails) throws ResourceNotFoundException;
    void delete(Long id) throws ResourceNotFoundException;
}