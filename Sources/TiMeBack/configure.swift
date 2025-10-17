import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import FluentSQL

public func configure(_ app: Application) async throws {
    app.routes.defaultMaxBodySize = "10mb"
    
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080
    
    // Configuration globale pour encoder/décoder les dates en ISO8601 de Vapor vers Swift
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    ContentConfiguration.global.use(decoder: decoder, for: .json)
    
    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "127.0.0.1",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 3306,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "TiMeDatabase"
    ), as: .mysql)
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .custom("http://127.0.0.1:5500"),
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin],
        cacheExpiration: 120
    )
    
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(corsMiddleware)
    
    app.get("byType") { req -> Response in
        let acceptHeader = req.headers["Accept"].first ?? ""
        switch acceptHeader {
            
        case "application/json":
            let userJson = try UserPublicDTO(from: User())
            return try Response(
                status: .ok,
                body: .init(data: JSONEncoder().encode(userJson)))
            
        case "text/html":
//            let user = try UserPublicDTO(from: User())
            let userHtml = "<p> Bonjour! </p>"
            return Response(
                status: .ok,
                body: .init(string: userHtml))
            
        default:
            let defaultResponse = "Type non initialisé"
            return Response(
                status: .ok,
                body: .init(string: defaultResponse))
        }
        
    }
    
    //    if let sql = app.db(.mysql) as? (any SQLDatabase) {
    //        sql.raw("SELECT 1").run().whenComplete { response in
    //            print(response)
    //        }
    //    } else {
    //        print("⚠️ Le driver SQL n'est pas disponible (cast vers SQLDatabase impossible)")
    //    }
    
    
    // register routes
    try routes(app)
}
