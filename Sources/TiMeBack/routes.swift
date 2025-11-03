import Fluent
import Vapor

func routes(_ app: Application) throws {
app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    try app.register(collection: UserController())
    try app.register(collection: ChallengeController())
    try app.register(collection: ChallengeOfTheDayController())
    try app.register(collection: EmotionController())
    try app.register(collection: EmotionCategoryController())
    try app.register(collection: EmotionOfTheDayController())
    try app.register(collection: HeartLevelController())
    try app.register(collection: MotivationController())
    try app.register(collection: PageController())
    try app.register(collection: DayController())
    try app.register(collection: StatementController())
    try app.register(collection: ExerciseController())
}
