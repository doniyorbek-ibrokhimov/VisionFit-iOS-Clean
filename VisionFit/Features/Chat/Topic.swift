//
//  Topic.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/04/25.
//

import SwiftUI

enum Topic: String, Identifiable, Hashable, CaseIterable {
    case cauDailySummary = "cau-daily-summary"
    case topTopicsAnonymous = "top-topics-anonymous"
    case attendanceVsPerformance = "attendance-vs-performance"
    case lectureTimeVsPerformance = "lecture-time-vs-performance"
    case thisWeeksAdmissionsVsLastYears = "this-weeks-admissions-vs-last-years"
    case studentTranscriptStudentIdName = "student-transcript-student-id-name"
    case failRateVsContentProvided = "fail-rate-vs-content-provided"
    case failRateVsAttendance = "fail-rate-vs-attendance"
    case studentProfessorVsFailRate = "student-professor-vs-fail-rate"
    
    var title: String {
        rawValue
    }
    
    var icon: Image {
        Image(systemName: "chart.bar")
    }
    
    var englishTranslation: String {
        switch self {
        case .cauDailySummary:
            return "CAU Daily Summary"
        case .topTopicsAnonymous:
            return "Top Anonymous Topics"
        case .attendanceVsPerformance:
            return "Attendance vs Performance"
        case .lectureTimeVsPerformance:
            return "Lecture Time vs Performance"
        case .thisWeeksAdmissionsVsLastYears:
            return "This Week's Admissions vs Last Year's"
        case .studentTranscriptStudentIdName:
            return "Student transcript [student_id/name]"
        case .failRateVsContentProvided:
            return "Fail Rate vs Content Provided"
        case .failRateVsAttendance:
            return "Fail rate vs Attendance"
        case .studentProfessorVsFailRate:
            return "Student/Professor vs Fail rate"
        }
    }
    
    var russianTranslation: String {
        switch self {
        case .cauDailySummary:
            return "Ежедневная сводка ЦАУ"
        case .topTopicsAnonymous:
            return "Топовые темы анонимно"
        case .attendanceVsPerformance:
            return "Посещаемость против успеваемости"
        case .lectureTimeVsPerformance:
            return "Время лекции против успеваемости"
        case .thisWeeksAdmissionsVsLastYears:
            return "Прием студентов на этой неделе по сравнению с прошлым годом"
        case .studentTranscriptStudentIdName:
            return "Транскрипт студента [студенческий_номер/имя]"
        case .failRateVsContentProvided:
            return "Уровень неуспеха против предоставленного контента"
        case .failRateVsAttendance:
            return "Уровень неуспеха против посещаемости"
        case .studentProfessorVsFailRate:
            return "Студент/Профессор против уровня неуспеха"
        }
    }
    
    var localizedTitle: String {
        switch AppCore.shared.language {
        case .en:
            return englishTranslation
        case .ru:
            return russianTranslation
        }
    }
    
    var description: LocalizedStringKey {
        .init(title)
    }
    
    var id: String { self.rawValue }
}
