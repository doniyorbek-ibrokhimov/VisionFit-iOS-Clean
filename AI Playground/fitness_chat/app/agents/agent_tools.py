import httpx
from typing import List
from agents import function_tool

from app.core.config import get_settings
from app.schemas.agent_schemas import (
    Attendance,
    AttendanceResponse,
    SchoolPerformanceData,
    SchoolsPerformanceList,
    StudentEnrollmentByGender,
    StudentRetakeRatioReport,
    ElectiveModuleData,
    FailureCountData,
    ElectiveEnrollmentReport,
    StudentInfoRecord,
    AnonymousMessage,
    TimetableEventInfoEvent,
)

session = httpx.Client()

settings = get_settings()


@function_tool
def get_attendance_statistics() -> AttendanceResponse:
    """Get attendance statistics from Eduplus returns all attendance by schools"""

    response = session.post(
        settings.EDUPLUS_URL + "/api/v3/analytics/average-attendance",
        headers={
            "Authorization": f"{settings.EDUPLUS_TOKEN}",
        },
    )
    response = response.json()
    attendance = [Attendance(**item) for item in response]
    return AttendanceResponse(attendance=attendance)


@function_tool
def get_enrollment_by_gender() -> StudentEnrollmentByGender:
    """Get enrollment statistics by gender (female VS male ratio) from Eduplus returns all enrollment by gender
    this is the total number of students of this gender across all programs
    """
    response = session.post(
        settings.EDUPLUS_URL + "/api/analytics/quantity-of-students-by-gender",
        headers={
            "Authorization": f"{settings.EDUPLUS_TOKEN}",
        },
    )
    response = response.json()
    return StudentEnrollmentByGender.model_validate(response)


@function_tool
def get_schools_performance(
    from_semester: int, to_semester: int, level: int
) -> SchoolsPerformanceList:
    """Get schools performance (average GPA) from Eduplus returns all schools performance
    to get full average GPA by school use level 0
    Args:
        from_semester (int, optional): Start semester. Defaults to 9. which is FALL-2024
        to_semester (int, optional): End semester. Defaults to 9 which is FALL-2024
        level (int, from 1 to 6): Level. Defaults to 0. freshman = 1, senior medical student = 6
    """
    payload = {"from_semester": from_semester, "to_semester": to_semester}
    if level != 0:
        payload["level"] = level
    response = session.post(
        settings.EDUPLUS_URL + "/api/v3/analytics/average-gpa-by-school",
        headers={
            "Authorization": f"{settings.EDUPLUS_TOKEN}",
        },
        json=payload,
    )
    response = response.json()
    performance = [SchoolPerformanceData(**item) for item in response]
    return SchoolsPerformanceList(schools=performance)


@function_tool
def get_student_retake_fail_ratio() -> StudentRetakeRatioReport:
    """Get student retake ratio which includes failed subjects from Eduplus returns all student retake ratio"""
    response = session.post(
        settings.EDUPLUS_URL + "/api/v3/analytics/student-retakes-ratio",
        headers={
            "Authorization": f"{settings.EDUPLUS_TOKEN}",
        },
    )
    response = response.json()
    fail_ratio = [FailureCountData(**item) for item in response]
    return StudentRetakeRatioReport(failure_data=fail_ratio)


@function_tool
def get_elective_enrollment() -> ElectiveEnrollmentReport:
    """Get elective enrollment from Eduplus returns all elective enrollment"""
    response = session.post(
        settings.EDUPLUS_URL + "/api/v4/analytics/get-elective-course-student-count",
        headers={
            "Authorization": f"{settings.EDUPLUS_TOKEN}",
        },
    )
    response = response.json()
    elective_enrollment = [ElectiveModuleData(**item) for item in response]
    return ElectiveEnrollmentReport(modules=elective_enrollment)


@function_tool
def get_student_info_transcript(student_id: str) -> StudentInfoRecord:
    """Get student transcript and studied subjects with grades and credits by student ID it is unique identifier for the student
    e.g student_id = 210030
    """
    response_uid = session.post(
        settings.EDUPLUS_URL + "/api/students/student/get-one-student-with-uid",
        headers={
            "Authorization": f"{settings.EDUPLUS_TOKEN}",
        },
        json={"uid": student_id},
    )
    response_uid = response_uid.json()
    if not response_uid:
        raise ValueError("Student not found")
    id_student = response_uid["id"]
    response = session.post(
        settings.EDUPLUS_URL + "/api/transcript/v4/transcript",
        headers={
            "Authorization": f"{settings.EDUPLUS_TOKEN}",
        },
        json={"student_id": id_student},
    )
    response = response.json()
    if not response:
        raise ValueError("Transcript not found")
    return StudentInfoRecord(**response)


@function_tool
def get_anonymous_messages(date: str) -> List[AnonymousMessage]:
    """Get anonymous messages by date YYYY-MM-DD"""
    response = session.get(
        "http://bot:3000" + f"/messages?date={date}",
    )
    response = response.json()
    if not response:
        raise ValueError("No anonymous messages found")
    messages = [AnonymousMessage(**item) for item in response]
    return messages


@function_tool
def get_class_held_info(from_date: str, to_date: str) -> List[TimetableEventInfoEvent]:
    """Get class held info by date range YYYY-MM-DD
    this includes all timetable events and classes start end times
    """
    page = 1
    limit = 50
    page_response = session.post(
        settings.EDUPLUS_URL + "/api/v4/analytics/teacher-event-details",
        headers={
            "Authorization": f"{settings.EDUPLUS_TOKEN}",
        },
        json={
            "filter": {"from_date": from_date, "to_date": to_date},
            "pagination": {"page": page, "limit": limit},
        },
    )
    response = page_response.json()
    if not response:
        raise ValueError("No class held info found")
    all_data = [i for i in response['data']]
    total_pages = response['total']
    while total_pages != 0:
        page += 1
        page_response = session.post(
            settings.EDUPLUS_URL + "/api/v4/analytics/teacher-event-details",
            headers={
                "Authorization": f"{settings.EDUPLUS_TOKEN}",
            },
            json={
                "filter": {"from_date": from_date, "to_date": to_date},
                "pagination": {"page": page, "limit": limit},
            },
        )
        response = page_response.json()
        if not response:
            raise ValueError("No class held info found")
        all_data.extend(response['data'])
        total_pages = response['total']
    return [TimetableEventInfoEvent(**item) for item in all_data]
