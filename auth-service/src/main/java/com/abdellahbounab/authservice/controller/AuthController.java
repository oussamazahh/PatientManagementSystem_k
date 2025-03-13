package com.abdellahbounab.authservice.controller;

import com.abdellahbounab.authservice.dto.LoginRequestDTO;
import com.abdellahbounab.authservice.dto.LoginResponseDTO;
import com.abdellahbounab.authservice.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @Operation(summary = "Generate token on user login")
    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> login (
            @RequestBody LoginRequestDTO loginRequestDTO
    ){
        log.info("login request entred");
        Optional<String> tokenOptional = authService.authenticate(loginRequestDTO);
        log.info("token is " + tokenOptional.orElse("is Empty"));

        if (tokenOptional.isEmpty()){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        log.info("login request succeded");
        return ResponseEntity.created(null).body(new LoginResponseDTO(tokenOptional.get()));
    }
}
