# PowerShell script to check current Firebase data
Write-Host "Checking current Firebase data..." -ForegroundColor Green

# Firebase project URL
$baseUrl = "https://firestore.googleapis.com/v1/projects/everycourse-e7654/databases/(default)/documents"

# Check users collection
Write-Host "=== Users Collection ===" -ForegroundColor Yellow
try {
    $usersResponse = Invoke-RestMethod -Uri "$baseUrl/users" -Method Get
    if ($usersResponse.documents) {
        foreach ($doc in $usersResponse.documents) {
            $docId = $doc.name.Split('/')[-1]
            $email = $doc.fields.email.stringValue
            $isStudent = if ($doc.fields.isStudent) { $doc.fields.isStudent.booleanValue } else { "N/A" }
            Write-Host "  $docId - Email: $email, isStudent: $isStudent" -ForegroundColor White
        }
    } else {
        Write-Host "  No users found" -ForegroundColor Gray
    }
} catch {
    Write-Host "  Error checking users: $($_.Exception.Message)" -ForegroundColor Red
}

# Check courses collection
Write-Host "=== Courses Collection ===" -ForegroundColor Yellow
try {
    $coursesResponse = Invoke-RestMethod -Uri "$baseUrl/courses" -Method Get
    if ($coursesResponse.documents) {
        foreach ($doc in $coursesResponse.documents) {
            $docId = $doc.name.Split('/')[-1]
            $title = $doc.fields.title.stringValue
            $createdBy = if ($doc.fields.createdBy) { $doc.fields.createdBy.stringValue } else { "N/A" }
            $showBadge = if ($doc.fields.showStudentBadge) { $doc.fields.showStudentBadge.booleanValue } else { "N/A" }
            Write-Host "  $docId - Title: $title, CreatedBy: $createdBy, StudentBadge: $showBadge" -ForegroundColor White
        }
    } else {
        Write-Host "  No courses found" -ForegroundColor Gray
    }
} catch {
    Write-Host "  Error checking courses: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Check completed!" -ForegroundColor Green
