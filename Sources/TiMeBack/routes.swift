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
}
