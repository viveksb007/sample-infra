variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "lambda_memory" {
  description = "Lambda memory in MB (128-10240)"
  type        = number
  default     = 512
  
  validation {
    condition     = var.lambda_memory >= 128 && var.lambda_memory <= 10240
    error_message = "Lambda memory must be between 128 and 10240 MB."
  }
}
