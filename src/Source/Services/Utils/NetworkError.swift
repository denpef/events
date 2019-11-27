enum NetworkError: Error {
    case badURL
    case decodingError(Error)
}
