# Simple Firebase upload test script
Write-Host "Starting Firebase test data upload..." -ForegroundColor Green

# Firebase project URL
$baseUrl = "https://firestore.googleapis.com/v1/projects/everycourse-911af/databases/(default)/documents"

# Regular user data
Write-Host "Adding regular user..." -ForegroundColor Cyan

$userData1 = @{
    fields = @{
        email = @{ stringValue = "user1@gmail.com" }
        displayName = @{ stringValue = "John Doe" }
        age = @{ integerValue = "25" }
        gender = @{ stringValue = "male" }
        isStudent = @{ booleanValue = $false }
    }
}

try {
    $json1 = $userData1 | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/users?documentId=user1" -Method Post -Body $json1 -ContentType "application/json"
    Write-Host "User1 added successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error adding user1: $($_.Exception.Message)" -ForegroundColor Red
}

# Unverified student user
Write-Host "Adding unverified student..." -ForegroundColor Cyan

$studentData = @{
    fields = @{
        email = @{ stringValue = "student@university.ac.kr" }
        displayName = @{ stringValue = "Student Kim" }
        age = @{ integerValue = "21" }
        gender = @{ stringValue = "female" }
        isStudent = @{ booleanValue = $false }
        emailVerified = @{ booleanValue = $false }
        studentVerificationStatus = @{ stringValue = "none" }
    }
}

try {
    $studentJson = $studentData | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/users?documentId=user-student" -Method Post -Body $studentJson -ContentType "application/json"
    Write-Host "Student user added!" -ForegroundColor Green
} catch {
    Write-Host "Error adding student: $($_.Exception.Message)" -ForegroundColor Red
}

# Verified student user
Write-Host "Adding verified student..." -ForegroundColor Cyan

$verifiedStudentData = @{
    fields = @{
        email = @{ stringValue = "verified@snu.ac.kr" }
        displayName = @{ stringValue = "Seoul Kim" }
        age = @{ integerValue = "22" }
        gender = @{ stringValue = "male" }
        isStudent = @{ booleanValue = $true }
        emailVerified = @{ booleanValue = $true }
        studentVerificationStatus = @{ stringValue = "verified" }
        universityEmail = @{ stringValue = "verified@snu.ac.kr" }
    }
}

try {
    $verifiedJson = $verifiedStudentData | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/users?documentId=user-verified-student" -Method Post -Body $verifiedJson -ContentType "application/json"
    Write-Host "Verified student added!" -ForegroundColor Green
} catch {
    Write-Host "Error adding verified student: $($_.Exception.Message)" -ForegroundColor Red
}

# Course data by verified student
Write-Host "Adding course..." -ForegroundColor Cyan

$courseData = @{
    fields = @{
        title = @{ stringValue = "Dating Basics for Students" }
        instructor = @{ stringValue = "Seoul Kim" }
        description = @{ stringValue = "A guide for healthy dating for university students" }
        category = @{ stringValue = "Dating" }
        createdBy = @{ stringValue = "user-verified-student" }
        isVerifiedInstructor = @{ booleanValue = $true }
        showStudentBadge = @{ booleanValue = $true }
        duration = @{ stringValue = "2 weeks" }
        difficulty = @{ stringValue = "beginner" }
    }
}

try {
    $courseJson = $courseData | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/courses?documentId=course-student" -Method Post -Body $courseJson -ContentType "application/json"
    Write-Host "Course added!" -ForegroundColor Green
} catch {
    Write-Host "Error adding course: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Upload completed!" -ForegroundColor Green
Write-Host "Test data structure:" -ForegroundColor Yellow
Write-Host "- user1: Regular user (isStudent=false)" -ForegroundColor White
Write-Host "- user-student: Unverified student (isStudent=false)" -ForegroundColor White  
Write-Host "- user-verified-student: Verified student (isStudent=true)" -ForegroundColor White
Write-Host "- course-student: Course with student badge" -ForegroundColor White
