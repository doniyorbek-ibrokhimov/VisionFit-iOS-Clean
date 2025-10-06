import SwiftUI
import QuickPoseCore

enum ExerciseType: CaseIterable, Identifiable {
    case bicepCurls
    case squat
    case pushUps
    case jumpingJacks
    case sumoSquats
    case lunges
    case sitUps
    case cobraWings
    case plank
    case plankStraightArm
    case legRaises
    case gluteBridge
    case overheadDumbbellPress
    case vUps
    case lateralRaises
    case frontRaises
    case hipAbductionStanding
    case sideLunges
    case bicepCurlsSingleArm

    var id: String { self.title }

    var title: String {
        switch self {
        case .squat:
            return "Squat"
        case .pushUps:
            return "Push Ups"
        case .jumpingJacks:
            return "Jumping Jacks"
        case .sumoSquats:
            return "Sumo Squats"
        case .lunges:
            return "Lunges"
        case .sitUps:
            return "Sit Ups"
        case .cobraWings:
            return "Cobra Wings"
        case .plank:
            return "Plank"
        case .plankStraightArm:
            return "Plank Straight Arm"
        case .legRaises:
            return "Leg Raises"
        case .gluteBridge:
            return "Glute Bridge"
        case .overheadDumbbellPress:
            return "Overhead Dumbbell Press"
        case .vUps:
            return "V Ups"
        case .lateralRaises:
            return "Lateral Raises"
        case .frontRaises:
            return "Front Raises"
        case .hipAbductionStanding:
            return "Hip Abduction Standing"
        case .sideLunges:
            return "Side Lunges"
        case .bicepCurls:
            return "Arm Raises"
        case .bicepCurlsSingleArm:
            return "Single Arm Bicep Curls"
        }
    }

    var image: Image {
        switch self {
        case .squat:
            return Image(.squatIcon)
        case .pushUps:
            return Image(.pushUp)
        case .jumpingJacks:
            return Image("jumpingJacks")
        case .sumoSquats:
            return Image("sumoSquats")
        case .lunges:
            return Image("lunges")
        case .sitUps:
            return Image("sitUps")
        case .cobraWings:
            return Image("cobraWings")
        case .plank:
            return Image("plank")
        case .plankStraightArm:
            return Image("plankStraightArm")
        case .legRaises:
            return Image("legRaises")
        case .gluteBridge:
            return Image("gluteBridge")
        case .overheadDumbbellPress:
            return Image("overheadDumbbellPress")
        case .vUps:
            return Image("vUps")
        case .lateralRaises:
            return Image("lateralRaises")
        case .frontRaises:
            return Image("frontRaises")
        case .hipAbductionStanding:
            return Image("hipAbductionStanding")
        case .sideLunges:
            return Image("sideLunges")
        case .bicepCurls:
            return Image(.armRaises)
        case .bicepCurlsSingleArm:
            return Image(.arm)
        }
    }

    var level: String {
        switch self {
        case .squat:
            return "Beginner"
        case .pushUps:
            return "Intermediate"
        case .jumpingJacks:
            return "Beginner"
        case .sumoSquats:
            return "Beginner"
        case .lunges:
            return "Intermediate"
        case .sitUps:
            return "Intermediate"
        case .cobraWings:
            return "Beginner"
        case .plank:
            return "Intermediate"
        case .plankStraightArm:
            return "Advanced"
        case .legRaises:
            return "Intermediate"
        case .gluteBridge:
            return "Beginner"
        case .overheadDumbbellPress:
            return "Intermediate"
        case .vUps:
            return "Advanced"
        case .lateralRaises:
            return "Beginner"
        case .frontRaises:
            return "Beginner"
        case .hipAbductionStanding:
            return "Beginner"
        case .sideLunges:
            return "Intermediate"
        case .bicepCurls:
            return "Beginner"
        case .bicepCurlsSingleArm:
            return "Intermediate"
        }
    }

    var description: String {
        switch self {
        case .squat:
            return """
            Lower body by bending knees and hips until thighs are parallel to floor, then return to standing. 
            Common form issues: knees caving inward, weight shifting to toes, insufficient depth.
            Targets quads, hamstrings, glutes. Proper form requires chest up, back straight.
            """
        case .pushUps:
            return """
            Start in plank position, lower body until chest nearly touches floor, then push back up. 
            Common issues: sagging hips, improper hand placement, incomplete range of motion.
            Works chest, shoulders, triceps, core. Progress by adjusting hand width or elevation.
            """
        case .jumpingJacks:
            return """
            Jumping with legs spreading wide and arms raising overhead simultaneously, then returning to starting position.
            Focus on rhythm and full range of motion. Common issues: incomplete arm movement, shallow jumps.
            Full-body cardio exercise improving coordination and elevating heart rate.
            """
        case .sumoSquats:
            return """
            Wide-stance squat with toes pointed outward 45°, lowering until thighs are parallel to floor. 
            Common issues: knees not tracking over toes, insufficient depth, poor back alignment.
            Targets inner thighs, glutes, quads. Maintain upright torso throughout movement.
            """
        case .lunges:
            return """
            Step forward into split stance, lower body until both knees reach 90°, then return to standing.
            Common issues: knee extending past toes, torso leaning forward, back knee not lowering enough.
            Works quads, hamstrings, glutes. Maintain vertical torso and balanced weight distribution.
            """
        case .sitUps:
            return """
            Lying on back with knees bent, raise upper body to sitting position, then lower back down.
            Common issues: using momentum, neck strain, feet lifting off ground.
            Strengthens core and hip flexors. Proper form keeps lower back pressed to floor during movement.
            """
        case .cobraWings:
            return """
            Lying prone, lift chest while drawing shoulder blades together and arms in winglike position.
            Common issues: lifting too high, neck strain, insufficient shoulder retraction.
            Strengthens upper back, shoulders, improves posture. Focus on controlled movement.
            """
        case .plank:
            return """
            Hold body in straight line from head to heels, supported by forearms and toes.
            Common issues: sagging hips, elevated hips, head dropping, shoulder tension.
            Engages entire core and shoulders. Progress by increasing hold time or reducing points of contact.
            """
        case .plankStraightArm:
            return """
            Standard plank position with arms fully extended and hands directly under shoulders.
            Common issues: sagging/lifted hips, protracted shoulder blades, locked elbows.
            Challenges core stability and shoulder strength more than standard plank. Maintain neutral spine.
            """
        case .legRaises:
            return """
            Lying on back, lift straight legs toward ceiling then lower without touching floor.
            Common issues: using momentum, arching lower back, insufficient range of motion.
            Targets lower abs and hip flexors. Keep lower back pressed into floor throughout movement.
            """
        case .gluteBridge:
            return """
            Lying on back with knees bent, lift hips toward ceiling until body forms straight line from shoulders to knees.
            Common issues: insufficient hip extension, overarching lower back, knees collapsing inward.
            Activates glutes, hamstrings, lower back. Squeeze glutes at top of movement.
            """
        case .overheadDumbbellPress:
            return """
            From standing position, press weights directly overhead from shoulder level until arms are extended.
            Common issues: arching back, forward head posture, insufficient shoulder mobility.
            Works shoulders, upper back, triceps. Maintain stable core and neutral spine throughout.
            """
        case .vUps:
            return """
            Simultaneously raise extended arms and legs from lying position to meet above torso, forming V-shape.
            Common issues: using momentum, incomplete range of motion, neck strain.
            Advanced core exercise requiring significant strength and control. Focus on controlled movement.
            """
        case .lateralRaises:
            return """
            Standing with weights at sides, lift arms out to sides until parallel with floor.
            Common issues: using momentum, shrugging shoulders, excessive wrist flexion.
            Isolates lateral deltoids for shoulder definition. Keep slight bend in elbows, maintain controlled motion.
            """
        case .frontRaises:
            return """
            Lifting weights straight in front from thighs to shoulder height with palms facing down.
            Common issues: using momentum, arching back, lifting too high above shoulders.
            Targets front deltoids. Maintain neutral spine and controlled tempo throughout movement.
            """
        case .hipAbductionStanding:
            return """
            Standing on one leg, lift other leg directly out to side while maintaining upright posture.
            Common issues: leaning torso, rotating hip, lifting leg forward instead of laterally.
            Strengthens hip abductors and improves stability. Keep standing leg slightly bent, maintain neutral pelvis.
            """
        case .sideLunges:
            return """
            Step wide to side and bend one knee while keeping other leg straight, lowering hips toward bent knee.
            Common issues: insufficient depth, knee collapsing inward, upper body leaning too far forward.
            Works inner/outer thighs, glutes, quads. Keep chest up and weight in heel of bent leg.
            """
        case .bicepCurls:
            return """
            Bending at elbow to curl weight toward shoulders. 
            Exercise contains two parts: User needs to complete rounds for Right arm first and then after completing right arm rounds, moves to left arm.
            User needs to keep their shoulders, hips, and legs in a straight line for proper form
            """
        case .bicepCurlsSingleArm:
            return """
            One arm bicep curl focusing on form for each side separately.
            Common issues: compensating with torso movement, wrist flexion, incomplete range of motion.
            Allows better focus on proper technique and identifying strength imbalances between arms.
            Maintain stable core and neutral spine throughout movement.
            """
        }
    }

    var progress: CGFloat {
        switch self {
        case .squat:
            return 0.5
        case .pushUps:
            return 0.7
        case .jumpingJacks:
            return 0.4
        case .sumoSquats:
            return 0.6
        case .lunges:
            return 0.5
        case .sitUps:
            return 0.6
        case .cobraWings:
            return 0.3
        case .plank:
            return 0.8
        case .plankStraightArm:
            return 0.9
        case .legRaises:
            return 0.6
        case .gluteBridge:
            return 0.4
        case .overheadDumbbellPress:
            return 0.7
        case .vUps:
            return 0.8
        case .lateralRaises:
            return 0.5
        case .frontRaises:
            return 0.5
        case .hipAbductionStanding:
            return 0.4
        case .sideLunges:
            return 0.6
        case .bicepCurls:
            return 0.5
        case .bicepCurlsSingleArm:
            return 0.7
        }
    }
}
