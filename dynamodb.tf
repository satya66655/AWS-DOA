# Students Table
resource "aws_dynamodb_table" "students" {
  name         = "student-enrollment-students"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "student_id"

  attribute {
    name = "student_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = {
    Name = "student-enrollment-students"
  }
}

# Courses Table
resource "aws_dynamodb_table" "courses" {
  name         = "student-enrollment-courses"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "course_id"

  attribute {
    name = "course_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = {
    Name = "student-enrollment-courses"
  }
}

# Enrollments Table with GSI
resource "aws_dynamodb_table" "enrollments" {
  name         = "student-enrollment-enrollments"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "enrollment_id"

  attribute {
    name = "enrollment_id"
    type = "S"
  }

  attribute {
    name = "student_id"
    type = "S"
  }

  global_secondary_index {
    name            = "student-id-index"
    hash_key        = "student_id"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = {
    Name = "student-enrollment-enrollments"
  }
}
