package com.example.demo.domain.maintenanceRequest.controller;

import com.example.demo.domain.maintenanceRequest.model.MaintenanceRequest;
import com.example.demo.domain.maintenanceRequest.services.MaintenanceRequestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/maintenance-requests")
public class MaintenanceRequestController {

    private final MaintenanceRequestService maintenanceRequestService;

    @Autowired
    public MaintenanceRequestController(MaintenanceRequestService maintenanceRequestService) {
        this.maintenanceRequestService = maintenanceRequestService;
    }

    @GetMapping
    public ResponseEntity<List<MaintenanceRequest>> getAll() {
        List<MaintenanceRequest> requests = maintenanceRequestService.getAll();
        return new ResponseEntity<>(requests, HttpStatus.OK);
    }

    @PostMapping
    public ResponseEntity<MaintenanceRequest> create(@RequestBody MaintenanceRequest request) {
        request = maintenanceRequestService.create(request);
        return new ResponseEntity<>(request, HttpStatus.CREATED);
    }

    @GetMapping("{id}")
    public ResponseEntity<MaintenanceRequest> getById(@PathVariable("id") Long id) {
        MaintenanceRequest request = maintenanceRequestService.getById(id);
        return new ResponseEntity<>(request, HttpStatus.OK);
    }

    @GetMapping("lookup")
    public ResponseEntity<MaintenanceRequest> getByEmail(@RequestParam String email) {
        MaintenanceRequest request = maintenanceRequestService.getByEmail(email);
        return new ResponseEntity<>(request, HttpStatus.OK);
    }

    @PutMapping("{id}")
    public ResponseEntity<MaintenanceRequest> update(@PathVariable("id") Long id, @RequestBody MaintenanceRequest requestDetails) {
        requestDetails = maintenanceRequestService.update(id, requestDetails);
        return new ResponseEntity<>(requestDetails, HttpStatus.ACCEPTED);
    }

    @DeleteMapping("{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") Long id) {
        maintenanceRequestService.delete(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}

