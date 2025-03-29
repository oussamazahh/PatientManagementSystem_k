package com.abdellahbounab.authservice.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class LoginRequestDTO {
        @NotBlank(message = "Email is Required") @Email(message = "Email should be valid")
        private String email;
        @NotBlank(message = "Password is Required")
        @Size(min = 8, message = "at least 8 Characters long!")
        private String password;

        public @NotBlank(message = "Email is Required") @Email(message = "Email should be valid") String getEmail() {
                return email;
        }

        public void setEmail(@NotBlank(message = "Email is Required") @Email(message = "Email should be valid") String email) {
                this.email = email;
        }

        public @NotBlank(message = "Password is Required") @Size(min = 8, message = "at least 8 Characters long!") String getPassword() {
                return password;
        }

        public void setPassword(@NotBlank(message = "Password is Required") @Size(min = 8, message = "at least 8 Characters long!") String password) {
                this.password = password;
        }
}
