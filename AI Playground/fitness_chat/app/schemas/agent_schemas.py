from pydantic import BaseModel, Field
from typing import List
from datetime import datetime
from typing import Optional



class Attendance(BaseModel):
    school_id: str
    title: str
    attendance_percentage: int


class AttendanceResponse(BaseModel):
    attendance: List[Attendance]
    

# gender by students


class SchoolProgram(BaseModel):
    total: int = Field(description="Total number of students enrolled in this program")
    school_name: str = Field(description="Name of the school or program")

class GenderEnrollmentData(BaseModel):
    sum: int = Field(description="Total number of students of this gender across all programs")
    programs: List[SchoolProgram] = Field(description="Breakdown of enrollment by school program")

class StudentEnrollmentByGender(BaseModel):
    male: GenderEnrollmentData = Field(description="Enrollment data for male students")
    female: GenderEnrollmentData = Field(description="Enrollment data for female students")
    not_set: GenderEnrollmentData = Field(description="Enrollment data for students with unspecified gender")
    
    class Config:
        title = "Student Enrollment Statistics By Gender"
        description = "Comprehensive breakdown of student enrollment data categorized by gender and academic programs"



#https://lms.eduplus.uz/api/v3/analytics/average-gpa-by-school


class SchoolPerformanceData(BaseModel):
    average_gpa: str = Field(description="Average GPA of students in the school")
    title: str = Field(description="Name of the school")
    id: str = Field(description="Unique identifier for the school")

class SchoolsPerformanceList(BaseModel):
    schools: List[SchoolPerformanceData] = Field(description="List of schools with their performance metrics")
    
    class Config:
        title = "Schools Performance Data"
        description = "Academic performance data for different schools including average GPAs"




#https://bobdev-2790.postman.co/workspace/bobdev-Workspace~ce8bce9c-a883-43e1-80d3-e827945a7951/request/21160130-d51cef6a-0b67-45b1-8982-d9dfc7eef1fe?action=share&source=copy-link&creator=21160130&active-environment=0f30fac3-fcbc-43a9-93d1-bbe8c9999a72

class SchoolFailureData(BaseModel):
    total_count: int = Field(description="Number of students failing at this school for this fail count")
    school_title: str = Field(description="Name of the school")

class FailureCountData(BaseModel):
    fail_count_number: str = Field(description="The number of times students have failed")
    total_fails_count: int = Field(description="Total number of students with this failure count across all schools")
    fails_by_school: List[SchoolFailureData] = Field(
        description="Breakdown of failures by school for this fail count number"
    )

class StudentRetakeRatioReport(BaseModel):
    failure_data: List[FailureCountData] = Field(
        description="List of failure count data organized by the number of times students have failed"
    )
    
    class Config:
        title = "Student Retake Ratio Report"
        description = "Detailed breakdown of student failure counts and retake patterns across different schools"



# https://bobdev-2790.postman.co/workspace/bobdev-Workspace~ce8bce9c-a883-43e1-80d3-e827945a7951/request/21160130-07a8a5bc-45f6-46c4-99b5-14887afac397?action=share&source=copy-link&creator=21160130&active-environment=0f30fac3-fcbc-43a9-93d1-bbe8c9999a72

class ElectiveCourseInfo(BaseModel):
    id: str = Field(description="Unique identifier for the course")
    title: str = Field(description="Title of the elective module/course")

class ElectiveModuleData(BaseModel):
    course_info: ElectiveCourseInfo = Field(description="Basic information about the elective module")
    student_count: int = Field(description="Number of students enrolled in this elective module")

class ElectiveEnrollmentReport(BaseModel):
    modules: List[ElectiveModuleData] = Field(
        description="List of elective modules with their enrollment counts"
    )
    
    class Config:
        title = "Elective Modules Enrollment Report"
        description = "Detailed breakdown of student enrollment across various elective modules"
        
    def total_students(self) -> int:
        """Calculate the total number of students enrolled across all elective modules"""
        return sum(module.student_count for module in self.modules)
    
    def popular_modules(self, threshold: int = 50) -> List[ElectiveModuleData]:
        """Return modules with enrollment above the specified threshold"""
        return [module for module in self.modules if module.student_count >= threshold]



class StudentInfoPDF(BaseModel):
    """Represents a PDF document associated with student information"""
    id: Optional[str] = Field(None, description="Unique identifier for the PDF document")
    name: Optional[str] = Field(None, description="Name of the PDF file")
    size: Optional[int] = Field(None, description="Size of the PDF file in bytes")
    type: Optional[str] = Field(None, description="MIME type of the file")
    created_at: Optional[datetime] = Field(None, description="Timestamp when the PDF was created")
    bucket_name: Optional[str] = Field(None, description="Storage bucket name where the PDF is stored")
    file_upload_job_status: Optional[str] = Field(None, description="Status of the file upload job, if applicable")


class StudentInfoModule(BaseModel):
    """Represents an academic module (course) taken by a student"""
    gpa: Optional[float] = Field(None, description="Grade Point Average achieved in this module")
    code: Optional[str] = Field(None, description="Course code identifier")
    name: Optional[str] = Field(None, description="Full name of the course")
    grade: Optional[str] = Field(None, description="Letter grade achieved (e.g., 'A+', 'B-')")
    retake: Optional[bool] = Field(None, description="Flag indicating if this course is marked for retake")
    credits: Optional[int] = Field(None, description="Number of credits for this course")
    is_failed: Optional[bool] = Field(None, description="Flag indicating if the course was failed")
    is_retake: Optional[bool] = Field(None, description="Flag indicating if this is a retake attempt")
    is_elective: Optional[bool] = Field(None, description="Flag indicating if this is an elective course")
    retake_credits: Optional[int] = Field(None, description="Number of credits counted after retake")


class StudentInfoSemester(BaseModel):
    """Represents a semester of academic study"""
    modules: Optional[List[StudentInfoModule]] = Field(None, description="List of modules taken in this semester")
    semester: Optional[str] = Field(None, description="Semester identifier (e.g., 'FALL 2021')")
    student_id: Optional[str] = Field(None, description="Student identifier this semester belongs to")
    overall_gpa: Optional[str] = Field(None, description="Overall GPA for the semester")
    total_credits: Optional[int] = Field(None, description="Total credits earned in this semester")
    elective_modules: Optional[List] = Field(None, description="List of elective modules taken in this semester")


class StudentInfoData(BaseModel):
    """Contains comprehensive student academic and personal data"""
    id: Optional[str] = Field(None, description="Unique identifier for the student record")
    uid: Optional[str] = Field(None, description="Student university ID number")
    level: Optional[int] = Field(None, description="Academic level or year of the student")
    program: Optional[str] = Field(None, description="Academic program the student is enrolled in")
    last_name: Optional[str] = Field(None, description="Student's last name")
    semesters: Optional[List[StudentInfoSemester]] = Field(None, description="List of semesters with academic records")
    birth_date: Optional[str] = Field(None, description="Student's date of birth (YYYY-MM-DD)")
    first_name: Optional[str] = Field(None, description="Student's first name")
    date_of_issue: Optional[str] = Field(None, description="Date when this record was issued")
    acceptance_year: Optional[int] = Field(None, description="Year when the student was accepted to the university")


class StudentInfoRecord(BaseModel):
    """Root model representing the complete student record"""
    id: Optional[str] = Field(None, description="Unique identifier for this student record")
    student_uid: Optional[int] = Field(None, description="Student university ID number as integer")
    student_id: Optional[str] = Field(None, description="Student ID as string")
    created_at: Optional[datetime] = Field(None, description="Timestamp when this record was created")
    created_by: Optional[str] = Field(None, description="ID of the person or system that created this record")
    pdf: Optional[StudentInfoPDF] = Field(None, description="PDF document associated with this record")
    data: Optional[StudentInfoData] = Field(None, description="Comprehensive student data")
    type: Optional[str] = Field(None, description="Type of record (e.g., 'studying')")



class AnonymousMessage(BaseModel):
    id: int = Field(description="Unique identifier for the anonymous message")
    message_id: int = Field(description="ID of the message")
    chat_id: int = Field(description="ID of the chat")
    text: str = Field(description="Text of the message")
    date: datetime = Field(description="Timestamp when the message was created")
    chat_title: str = Field(description="Title of the channel that message was sent")

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }



class TimetableEventInfoEvent(BaseModel):
    """
    Represents a single event in the timetable.
    """
    total: int = Field(..., description="Total number of events (appears consistent across entries).")
    first_name: str = Field(..., description="First name of the teacher.")
    last_name: str = Field(..., description="Last name of the teacher.")
    teacher_school: Optional[str] = Field(None, description="The school or department the teacher belongs to.")
    email: str = Field(..., description="Teacher's email address.") # Consider using EmailStr for validation if needed
    course_name: str = Field(..., description="Name of the course.")
    course_code: str = Field(..., description="Unique code identifying the course.")
    room_name: str = Field(..., description="Name or description of the room.")
    room_code: str = Field(..., description="Code identifying the room.")
    seats: int = Field(..., description="Number of seats available in the room.")
    room_type: Optional[str] = Field(None, description="Type of the room (e.g., classroom, lecture_hall, lab). Can be null.")
    event_date: datetime = Field(..., description="The date of the event.")
    event_start: datetime = Field(..., description="Scheduled start time of the event.")
    event_end: datetime = Field(..., description="Scheduled end time of the event.")
    lesson_start: Optional[datetime] = Field(None, description="determines the is professor held the class, if not null")
    lesson_end: Optional[datetime] = Field(None, description="Actual end time of the lesson, if recorded. Can be null.")
    groups: List[str] = Field(..., description="List of student groups attending the event.")
    enroll_and_joined_student_count: int = Field(..., description="Count of students both enrolled and joined.")
    joined_student_count: int = Field(..., description="Count of students who actually joined the event/session.")