import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import StripePaymentSheet

// MARK: - Models Extendidos

struct Transaction: Identifiable, Codable {
    let id: UUID
    let type: String // "purchase", "spend", "reward", "download_cover", "download_comic"
    let amount: Int
    let description: String
    let date: Date
    var comicTitle: String?
    
    init(id: UUID = UUID(), type: String, amount: Int, description: String, date: Date = Date(), comicTitle: String? = nil) {
        self.id = id
        self.type = type
        self.amount = amount
        self.description = description
        self.date = date
        self.comicTitle = comicTitle
    }
}

struct CoinPackage: Identifiable {
    let id = UUID()
    let name: String
    let coins: Int
    let price: Double
    let discount: String?
    
    var pricePerCoin: Double {
        price / Double(coins)
    }
}

struct Comic: Identifiable, Codable {
    let id: UUID
    let title: String
    let issue: String
    let year: String
    var localImageName: String?
    let franchise: String
    let writer: String
    let artist: String
    var pdfFileName: String?
    let isUserAdded: Bool
    let coverPrice: Int? // Precio en monedas para descargar portada
    let comicPrice: Int? // Precio en monedas para descargar cómic completo (futuro)
    
    init(id: UUID = UUID(), title: String, issue: String, year: String, localImageName: String? = nil, franchise: String, writer: String, artist: String, pdfFileName: String? = nil, isUserAdded: Bool = false, coverPrice: Int? = 10, comicPrice: Int? = 50) {
        self.id = id
        self.title = title
        self.issue = issue
        self.year = year
        self.localImageName = localImageName
        self.franchise = franchise
        self.writer = writer
        self.artist = artist
        self.pdfFileName = pdfFileName
        self.isUserAdded = isUserAdded
        self.coverPrice = coverPrice
        self.comicPrice = comicPrice
    }
}

struct Collection: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var comicIDs: [UUID]
    var createdDate: Date
    var isUserCreated: Bool
    
    init(id: UUID = UUID(), name: String, description: String = "", comicIDs: [UUID] = [], createdDate: Date = Date(), isUserCreated: Bool = true) {
        self.id = id
        self.name = name
        self.description = description
        self.comicIDs = comicIDs
        self.createdDate = createdDate
        self.isUserCreated = isUserCreated
    }
}

struct Review: Identifiable, Codable {
    let id: UUID
    let comicID: UUID
    var rating: Int
    var title: String
    var content: String
    let createdDate: Date
    var lastModified: Date?
    
    init(id: UUID = UUID(), comicID: UUID, rating: Int, title: String, content: String, createdDate: Date = Date(), lastModified: Date? = nil) {
        self.id = id
        self.comicID = comicID
        self.rating = rating
        self.title = title
        self.content = content
        self.createdDate = createdDate
        self.lastModified = lastModified
    }
}

struct UserProfile: Codable {
    var name: String
    var email: String
    var joinedDate: Date
    var favorites: [UUID]
    var coins: Int
    var purchasedCovers: [UUID] // IDs de cómics cuyas portadas fueron compradas
    var purchasedComics: [UUID] // IDs de cómics completos comprados (futuro)
    var transactions: [Transaction]
    
    init(name: String = "Usuario", email: String = "usuario@comics.com", joinedDate: Date = Date(), favorites: [UUID] = [], coins: Int = 50, purchasedCovers: [UUID] = [], purchasedComics: [UUID] = [], transactions: [Transaction] = []) {
        self.name = name
        self.email = email
        self.joinedDate = joinedDate
        self.favorites = favorites
        self.coins = coins
        self.purchasedCovers = purchasedCovers
        self.purchasedComics = purchasedComics
        self.transactions = transactions
    }
}

struct ComicSection: Identifiable {
    let id = UUID()
    let title: String
    let comics: [Comic]
}

// MARK: - UI Components

// Coin Badge View
struct CoinBadgeView: View {
    let coins: Int
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: size))
                .foregroundColor(.yellow)
            
            Text("\(coins)")
                .font(.system(size: size * 0.8, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [.orange.opacity(0.8), .yellow.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: .yellow.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// Download Button View
struct DownloadButtonView: View {
    let title: String
    let icon: String
    let price: Int?
    let isPurchased: Bool
    let action: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isAnimating = false
            }
            action()
        }) {
            HStack(spacing: 8) {
                if isPurchased {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                } else if let price = price {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text("\(price)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                } else {
                    Image(systemName: icon)
                        .foregroundColor(.gray)
                        .font(.title3)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                isPurchased ?
                Color.green.opacity(0.1) :
                    (price != nil ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isPurchased ? Color.green.opacity(0.3) :
                            (price != nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3)),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isAnimating ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Coin Package Card
struct CoinPackageCard: View {
    let package: CoinPackage
    let action: () -> Void
    @State private var isPressing = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Header con oferta si hay descuento
                if let discount = package.discount {
                    Text(discount)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(6)
                }
                
                // Cantidad de monedas
                VStack(spacing: 8) {
                    Text("\(package.coins)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title3)
                            .foregroundColor(.yellow)
                        
                        Text("MONEDAS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }
                
                // Precio
                VStack(spacing: 4) {
                    Text("$\(String(format: "%.2f", package.price))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if package.coins > 100 {
                        Text("$\(String(format: "%.4f", package.pricePerCoin)) por moneda")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                // Mejor valor si tiene el mejor precio por moneda
                if package.pricePerCoin <= 0.01 {
                    Label("MEJOR VALOR", systemImage: "crown.fill")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color(.systemGray5), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.yellow.opacity(0.5), .orange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressing ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressing = pressing
        }, perform: {})
    }
}

// Snackbar View
struct SnackbarView: View {
    let message: String
    let type: String // "success", "error", "info", "warning"
    @Binding var isShowing: Bool
    
    var icon: String {
        switch type {
        case "success": return "checkmark.circle.fill"
        case "error": return "xmark.circle.fill"
        case "info": return "info.circle.fill"
        case "warning": return "exclamationmark.triangle.fill"
        default: return "info.circle.fill"
        }
    }
    
    var color: Color {
        switch type {
        case "success": return .green
        case "error": return .red
        case "info": return .blue
        case "warning": return .yellow
        default: return .blue
        }
    }
    
    var body: some View {
        VStack {
            if isShowing {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title2)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding()
                .frame(height: 70)
                .background(Color.black.opacity(0.85))
                .cornerRadius(12)
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isShowing)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .zIndex(1000)
    }
}

// Circle Avatar View
struct CircleAvatarView: View {
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(.gray)
                .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 2))
        }
    }
}

// Star Rating View
struct StarRatingView: View {
    @Binding var rating: Int
    let maxRating: Int = 5
    let editable: Bool
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundColor(star <= rating ? .yellow : .gray)
                    .font(.system(size: size))
                    .onTapGesture {
                        if editable {
                            rating = star
                        }
                    }
            }
        }
    }
}

// Triángulo para el efecto globo
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct MenuItemRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.body)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .gray)
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Drawer Menu View - Actualizado con efecto globo
struct DrawerMenuView: View {
    @Binding var isShowing: Bool
    @Binding var selectedView: String
    let userProfile: UserProfile
    let onLogout: () -> Void
    
    let menuItems = [
        ("Inicio", "house.fill", "catalog"),
        ("Mis Cómics", "book.fill", "myComics"),
        ("Colecciones", "folder.fill", "collections"),
        ("Reseñas", "star.fill", "reviews"),
        ("Perfil", "person.fill", "profile"),
        ("Tienda", "cart.fill", "store")
    ]
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Fondo semi-transparente
            if isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isShowing = false
                        }
                    }
                    .transition(.opacity)
            }
            
            // Menú estilo globo
            if isShowing {
                VStack(alignment: .trailing, spacing: 0) {
                    // Triángulo/indicador del globo
                    Triangle()
                        .fill(Color(.systemGray6))
                        .frame(width: 20, height: 15)
                        .offset(x: -20, y: 0)
                    
                    // Contenido del menú
                    VStack(alignment: .leading, spacing: 0) {
                        // Header con avatar y monedas
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 15) {
                                CircleAvatarView(size: 50) {}
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(userProfile.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    Text(userProfile.email)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
                            
                            // Mostrar monedas disponibles
                            HStack {
                                CoinBadgeView(coins: userProfile.coins, size: 14)
                                Spacer()
                                Text("Disponibles")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 15)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal, 16)
                        
                        // Items del menú
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(menuItems, id: \.0) { item in
                                    MenuItemRow(
                                        title: item.0,
                                        icon: item.1,
                                        isSelected: selectedView == item.2,
                                        action: {
                                            selectedView = item.2
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                isShowing = false
                                            }
                                        }
                                    )
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                
                                Button(action: {
                                    onLogout()
                                    isShowing = false
                                }) {
                                    HStack(spacing: 15) {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.body)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.red)
                                        
                                        Text("Cerrar Sesión")
                                            .font(.headline)
                                            .foregroundColor(.red)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 15)
                                }
                            }
                        }
                        .frame(maxHeight: 350)
                    }
                    .frame(width: 280)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .padding(.trailing, 10)
                }
                .offset(y: 60)
                .transition(.scale(scale: 0.95, anchor: .topTrailing).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.2), value: isShowing)
            }
        }
    }
}

// Enhanced Comic Card
struct EnhancedComicCardView: View {
    let comic: Comic
    let width: CGFloat
    let height: CGFloat
    let showDetail: () -> Void
    @State private var isPressing = false
    
    var body: some View {
        Button(action: showDetail) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        if let imageName = comic.localImageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: width, height: height)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Color.blue.opacity(0.3)
                                .frame(width: width, height: height)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    Image(systemName: "book.closed")
                                        .foregroundColor(.white.opacity(0.5))
                                        .font(.system(size: 30))
                                )
                        }
                        
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(width: width, height: height)
                    
                    if comic.isUserAdded {
                        Text("NUEVO")
                            .font(.caption2)
                            .bold()
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .padding(8)
                    }
                    
                    // Indicador de precio de portada
                    if let price = comic.coverPrice {
                        HStack(spacing: 2) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            
                            Text("\(price)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                        .padding(8)
                        .offset(y: comic.isUserAdded ? 25 : 0)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(comic.title)
                        .font(.caption)
                        .bold()
                        .lineLimit(2)
                        .foregroundColor(.white)
                    
                    Text(comic.issue)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(width: width, alignment: .leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressing ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressing)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressing = pressing
        }, perform: {})
    }
}

// MARK: - Managers

class CoinManager: ObservableObject {
    @Published var availablePackages: [CoinPackage] = []
    
    init() {
        loadPackages()
    }
    
    private func loadPackages() {
        availablePackages = [
            CoinPackage(name: "Paquete Básico", coins: 100, price: 0.99, discount: nil),
            CoinPackage(name: "Paquete Popular", coins: 250, price: 1.99, discount: "AHORRA 20%"),
            CoinPackage(name: "Paquete Premium", coins: 500, price: 3.99, discount: "AHORRA 30%"),
            CoinPackage(name: "Paquete Coleccionista", coins: 1000, price: 6.99, discount: "MEJOR OFERTA"),
            CoinPackage(name: "Paquete Mega", coins: 2000, price: 11.99, discount: "50% OFF")
        ]
    }
}

class ComicManager: ObservableObject {
    @Published var userComics: [Comic] = []
    
    private let userDefaultsKey = "savedUserComics"
    
    init() {
        loadUserComics()
    }
    
    func addComic(_ comic: Comic) {
        userComics.append(comic)
        saveUserComics()
    }
    
    func updateComic(_ comic: Comic) {
        if let index = userComics.firstIndex(where: { $0.id == comic.id }) {
            userComics[index] = comic
            saveUserComics()
        }
    }
    
    func deleteComic(_ comic: Comic) {
        userComics.removeAll { $0.id == comic.id }
        saveUserComics()
    }
    
    private func saveUserComics() {
        if let encoded = try? JSONEncoder().encode(userComics) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUserComics() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Comic].self, from: savedData) {
            userComics = decoded
        }
    }
}

class CollectionManager: ObservableObject {
    @Published var collections: [Collection] = []
    
    private let userDefaultsKey = "userCollections"
    
    init() {
        loadCollections()
        createDefaultCollections()
    }
    
    private func createDefaultCollections() {
        if collections.isEmpty {
            let defaultCollections = [
                Collection(name: "Favoritos", description: "Mis cómics favoritos", isUserCreated: false),
                Collection(name: "Por Leer", description: "Cómics pendientes de lectura", isUserCreated: false),
                Collection(name: "Coleccionados", description: "Ediciones especiales", isUserCreated: false)
            ]
            collections = defaultCollections
            saveCollections()
        }
    }
    
    func createCollection(name: String, description: String = "") -> Collection {
        let newCollection = Collection(
            name: name,
            description: description
        )
        collections.append(newCollection)
        saveCollections()
        return newCollection
    }
    
    func updateCollection(_ collection: Collection, name: String? = nil, description: String? = nil, comicIDs: [UUID]? = nil) -> Bool {
        guard let index = collections.firstIndex(where: { $0.id == collection.id }) else { return false }
        
        var updatedCollection = collection
        
        if let name = name {
            updatedCollection.name = name
        }
        
        if let description = description {
            updatedCollection.description = description
        }
        
        if let comicIDs = comicIDs {
            updatedCollection.comicIDs = comicIDs
        }
        
        collections[index] = updatedCollection
        saveCollections()
        return true
    }
    
    func deleteCollection(_ collection: Collection) -> Bool {
        guard collection.isUserCreated else { return false }
        
        collections.removeAll { $0.id == collection.id }
        saveCollections()
        return true
    }
    
    func addComicToCollection(comicID: UUID, collectionID: UUID) -> Bool {
        guard let index = collections.firstIndex(where: { $0.id == collectionID }) else { return false }
        
        var collection = collections[index]
        if !collection.comicIDs.contains(comicID) {
            collection.comicIDs.append(comicID)
            collections[index] = collection
            saveCollections()
            return true
        }
        return false
    }
    
    func removeComicFromCollection(comicID: UUID, collectionID: UUID) -> Bool {
        guard let index = collections.firstIndex(where: { $0.id == collectionID }) else { return false }
        
        var collection = collections[index]
        collection.comicIDs.removeAll { $0 == comicID }
        collections[index] = collection
        saveCollections()
        return true
    }
    
    private func saveCollections() {
        if let encoded = try? JSONEncoder().encode(collections) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadCollections() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Collection].self, from: savedData) {
            collections = decoded
        }
    }
}

class ReviewManager: ObservableObject {
    @Published var reviews: [Review] = []
    
    private let userDefaultsKey = "userReviews"
    
    init() {
        loadReviews()
    }
    
    func createReview(comicID: UUID, rating: Int, title: String, content: String) -> Review {
        let newReview = Review(
            comicID: comicID,
            rating: rating,
            title: title,
            content: content
        )
        reviews.append(newReview)
        saveReviews()
        return newReview
    }
    
    func updateReview(_ review: Review, rating: Int? = nil, title: String? = nil, content: String? = nil) -> Bool {
        guard let index = reviews.firstIndex(where: { $0.id == review.id }) else { return false }
        
        var updatedReview = review
        
        if let rating = rating {
            updatedReview.rating = rating
        }
        
        if let title = title {
            updatedReview.title = title
        }
        
        if let content = content {
            updatedReview.content = content
        }
        
        updatedReview.lastModified = Date()
        reviews[index] = updatedReview
        saveReviews()
        return true
    }
    
    func deleteReview(_ review: Review) {
        reviews.removeAll { $0.id == review.id }
        saveReviews()
    }
    
    func getReviewsForComic(_ comicID: UUID) -> [Review] {
        reviews.filter { $0.comicID == comicID }
    }
    
    private func saveReviews() {
        if let encoded = try? JSONEncoder().encode(reviews) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadReviews() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Review].self, from: savedData) {
            reviews = decoded
        }
    }
}

class UserManager: ObservableObject {
    @Published var currentUser: UserProfile = UserProfile()
    @Published var isLoggedIn: Bool = true
    
    private let userDefaultsKey = "currentUser"
    
    init() {
        loadUser()
    }
    
    func updateUser(name: String? = nil, email: String? = nil) {
        if let name = name {
            currentUser.name = name
        }
        
        if let email = email {
            currentUser.email = email
        }
        
        saveUser()
    }
    
    func toggleFavorite(comicID: UUID) {
        if currentUser.favorites.contains(comicID) {
            currentUser.favorites.removeAll { $0 == comicID }
        } else {
            currentUser.favorites.append(comicID)
        }
        saveUser()
    }
    
    func isFavorite(comicID: UUID) -> Bool {
        currentUser.favorites.contains(comicID)
    }
    
    // MARK: - Sistema de Monedas
    
    func addCoins(_ amount: Int, reason: String) {
        objectWillChange.send() // UPDATE: Force UI update for coins
        currentUser.coins += amount
        let transaction = Transaction(
            type: "reward",
            amount: amount,
            description: reason,
            comicTitle: nil
        )
        currentUser.transactions.insert(transaction, at: 0)
        saveUser()
    }
    
    func spendCoins(_ amount: Int, comic: Comic, type: String) -> Bool {
        guard currentUser.coins >= amount else { return false }
        
        objectWillChange.send() // UPDATE: Force UI update for coins
        currentUser.coins -= amount
        
        let transaction = Transaction(
            type: type,
            amount: -amount,
            description: type == "download_cover" ? "Portada descargada" : "Cómic descargado",
            comicTitle: comic.title
        )
        currentUser.transactions.insert(transaction, at: 0)
        
        if type == "download_cover" {
            if !currentUser.purchasedCovers.contains(comic.id) {
                currentUser.purchasedCovers.append(comic.id)
            }
        } else if type == "download_comic" {
            if !currentUser.purchasedComics.contains(comic.id) {
                currentUser.purchasedComics.append(comic.id)
            }
        }
        
        saveUser()
        return true
    }
    
    func hasPurchasedCover(for comicID: UUID) -> Bool {
        currentUser.purchasedCovers.contains(comicID)
    }
    
    func hasPurchasedComic(for comicID: UUID) -> Bool {
        currentUser.purchasedComics.contains(comicID)
    }
    
    func simulatePurchase(package: CoinPackage) {
        // En una implementación real, aquí se integraría con Stripe
        // Por ahora simulamos la compra añadiendo monedas
        addCoins(package.coins, reason: "Compra de \(package.name)")
    }
    
    func logout() {
        currentUser = UserProfile()
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func login() {
        isLoggedIn = true
        saveUser()
    }
    
    private func saveUser() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUser() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: savedData) {
            currentUser = decoded
        }
    }
}

// MARK: - Data
let tendenciasComicsBase: [Comic] = [
    Comic(title: "All-Star Superman", issue: "#1", year: "2005", localImageName: "ASS", franchise: "DC", writer: "Grant Morrison", artist: "Frank Quitely", coverPrice: 10),
    Comic(title: "The Death of Superman", issue: "#75", year: "1993", localImageName: "Supermán", franchise: "DC", writer: "Dan Jurgens", artist: "Brett Breeding", coverPrice: 10),
    Comic(title: "Absolute Batman", issue: "#6", year: "2025", localImageName: "Batman2", franchise: "DC", writer: "Tini Howard", artist: "Mikel Janin", coverPrice: 15),
    Comic(title: "Batman: The Dark Knight Returns", issue: "#1", year: "1986", localImageName: "Batman3", franchise: "DC", writer: "Frank Miller", artist: "Frank Miller", pdfFileName: "dark_knight_returns.pdf", coverPrice: 20),
    Comic(title: "The Batman Who Laughs", issue: "#1", year: "2017", localImageName: "BWL", franchise: "DC", writer: "Scott Snyder", artist: "Jock", coverPrice: 15),
    Comic(title: "Spawn/Batman", issue: "One-Shot", year: "1994", localImageName: "SB", franchise: "Image", writer: "Frank Miller", artist: "Todd McFarlane", coverPrice: 12),
    Comic(title: "Spawn", issue: "#1", year: "1992", localImageName: "Spawn", franchise: "Image", writer: "Todd McFarlane", artist: "Todd McFarlane", coverPrice: 10),
    Comic(title: "Spawn", issue: "#285", year: "2018", localImageName: "Spawn.jpg", franchise: "Image", writer: "Todd McFarlane", artist: "Jason Shawn Alexander", coverPrice: 10),
    Comic(title: "Spawn", issue: "#97", year: "2000", localImageName: "Ángela", franchise: "Image", writer: "Brian Wood", artist: "Ashley Wood", coverPrice: 10),
    Comic(title: "Transformers", issue: "#12", year: "2024", localImageName: "TF2", franchise: "IDW", writer: "Robbie Robbins", artist: "Josh Burcham", coverPrice: 10),
    Comic(title: "Transformers", issue: "#18", year: "2025", localImageName: "TF5", franchise: "IDW", writer: "Simon Furman", artist: "Don Figueroa", coverPrice: 10),
    Comic(title: "Transformers", issue: "#16", year: "2025", localImageName: "Meg", franchise: "IDW", writer: "Jody Houser", artist: "Marco Cicirello", coverPrice: 10),
    Comic(title: "Transformers", issue: "#22", year: "2025", localImageName: "TF3", franchise: "IDW", writer: "Brian Ruckley", artist: "Anna Malkova", coverPrice: 10),
    Comic(title: "Transformers", issue: "#8", year: "2024", localImageName: "TF4", franchise: "IDW", writer: "Brandon Easton", artist: "Jack Lawrence", coverPrice: 10)
]

let nuevosComicsBase: [Comic] = [
    Comic(title: "X-Men (Vol. 2)", issue: "#1", year: "1991", localImageName: "Magneto", franchise: "Marvel", writer: "Chris Claremont", artist: "Jim Lee", coverPrice: 15),
    Comic(title: "The Amazing Spider-Man", issue: "#43", year: "2002", localImageName: "SPM", franchise: "Marvel", writer: "J. Michael Straczynski", artist: "John Romita Jr.", coverPrice: 15),
    Comic(title: "Psylocke", issue: "#1", year: "2024", localImageName: "Psy2", franchise: "Marvel", writer: "Tini Howard", artist: "Marco Checchetto", coverPrice: 10),
    Comic(title: "Psylocke", issue: "#7", year: "2025", localImageName: "Psy", franchise: "Marvel", writer: "Gerry Duggan", artist: "Russell Dauterman", coverPrice: 10),
    Comic(title: "Hulk", issue: "#9", year: "2022", localImageName: "Jolk", franchise: "Marvel", writer: "Donny Cates", artist: "Ryan Ottley", coverPrice: 12),
    Comic(title: "Web of Spider-Man", issue: "#32", year: "1987", localImageName: "SPM2", franchise: "Marvel", writer: "Roger Stern", artist: "Todd McFarlane", coverPrice: 15),
    Comic(title: "Magik", issue: "#3", year: "2025", localImageName: "Magik", franchise: "Marvel", writer: "Vita Ayala", artist: "Rod Reis", coverPrice: 10),
    Comic(title: "The Infinity Gauntlet", issue: "#1", year: "1991", localImageName: "Tunas", franchise: "Marvel", writer: "Jim Starlin", artist: "George Pérez", coverPrice: 20),
    Comic(title: "Transformers 84", issue: "#1", year: "2020", localImageName: "TF7", franchise: "IDW", writer: "Simon Furman", artist: "Guido Guidi", coverPrice: 10),
    Comic(title: "Grimlock", issue: "#1", year: "2022", localImageName: "Grimlock", franchise: "IDW", writer: "Daniel Warren Johnson", artist: "Daniel Warren Johnson", coverPrice: 10),
    Comic(title: "Transformers", issue: "#11", year: "2024", localImageName: "TF8", franchise: "IDW", writer: "Nick Roche", artist: "Nick Roche", coverPrice: 10),
    Comic(title: "Transformers", issue: "#5", year: "2024", localImageName: "TF9", franchise: "IDW", writer: "James Roberts", artist: "Alex Milne", coverPrice: 10),
    Comic(title: "Transformers 84", issue: "#23", year: "2023", localImageName: "TF6", franchise: "IDW", writer: "Chris Ryall", artist: "Andrew Wildman", coverPrice: 10),
    Comic(title: "Transformers", issue: "#16", year: "2025", localImageName: "Bruticus", franchise: "IDW", writer: "Simon Furman", artist: "E.J. Su", coverPrice: 10),
    Comic(title: "Energon Universe 2024", issue: "#1", year: "2024", localImageName: "Transformers1.jpg", franchise: "IDW", writer: "Robert Kirkman", artist: "Lorenzo De Felici", coverPrice: 15)
]

// MARK: - Vistas Faltantes

// 1. AddComicView
struct AddComicView: View {
    @ObservedObject var comicManager: ComicManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var issue = ""
    @State private var year = ""
    @State private var franchise = "DC"
    @State private var writer = ""
    @State private var artist = ""
    @State private var coverPrice = "10"
    @State private var comicPrice = "50"
    
    let franchises = ["DC", "Marvel", "IDW", "Image", "Dark Horse", "Vertigo"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información Básica")) {
                    TextField("Título", text: $title)
                    TextField("Número/Nombre de Issue", text: $issue)
                    TextField("Año", text: $year)
                        .keyboardType(.numberPad)
                    
                    Picker("Franquicia", selection: $franchise) {
                        ForEach(franchises, id: \.self) { franchise in
                            Text(franchise).tag(franchise)
                        }
                    }
                }
                
                Section(header: Text("Créditos")) {
                    TextField("Guionista", text: $writer)
                    TextField("Artista", text: $artist)
                }
                
                Section(header: Text("Precios en Monedas")) {
                    TextField("Precio Portada", text: $coverPrice)
                        .keyboardType(.numberPad)
                    
                    TextField("Precio Cómic Completo", text: $comicPrice)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button(action: saveComic) {
                        HStack {
                            Spacer()
                            Text("Guardar Cómic")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || issue.isEmpty)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Nuevo Cómic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveComic() {
        let newComic = Comic(
            title: title,
            issue: issue,
            year: year,
            franchise: franchise,
            writer: writer,
            artist: artist,
            isUserAdded: true,
            coverPrice: Int(coverPrice),
            comicPrice: Int(comicPrice)
        )
        
        comicManager.addComic(newComic)
        presentationMode.wrappedValue.dismiss()
    }
}

// 2. CollectionCardView
struct CollectionCardView: View {
    let collection: Collection
    @State private var isPressing = false
    
    var comicCount: Int {
        collection.comicIDs.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if !collection.isUserCreated {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(collection.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(collection.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "book.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text("\(comicCount) cómic\(comicCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Spacer()
                    
                    Text(formatDate(collection.createdDate))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(height: 150)
        .background(
            LinearGradient(
                colors: [Color(.systemGray6), Color(.systemGray5)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        .scaleEffect(isPressing ? 0.97 : 1.0)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// 3. AddCollectionView
struct AddCollectionView: View {
    @ObservedObject var collectionManager: CollectionManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información de la Colección")) {
                    TextField("Nombre", text: $name)
                    TextField("Descripción", text: $description)
                }
                
                Section {
                    Button(action: saveCollection) {
                        HStack {
                            Spacer()
                            Text("Crear Colección")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(name.isEmpty)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Nueva Colección")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveCollection() {
        _ = collectionManager.createCollection(name: name, description: description)
        presentationMode.wrappedValue.dismiss()
    }
}

// 4. CollectionDetailView
struct CollectionDetailView: View {
    let collection: Collection
    @ObservedObject var collectionManager: CollectionManager
    @ObservedObject var comicManager: ComicManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showAddComics = false
    @State private var showEditCollection = false
    @State private var showDeleteAlert = false
    
    var comicsInCollection: [Comic] {
        let allComics = tendenciasComicsBase + nuevosComicsBase + comicManager.userComics
        return allComics.filter { collection.comicIDs.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if comicsInCollection.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Colección vacía")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Añade cómics a esta colección")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(comicsInCollection) { comic in
                                EnhancedComicCardView(
                                    comic: comic,
                                    width: 120,
                                    height: 180,
                                    showDetail: {
                                        // Aquí deberías mostrar el detalle del cómic
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(collection.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { showAddComics = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        if collection.isUserCreated {
                            Menu {
                                Button(action: { showEditCollection = true }) {
                                    Label("Editar", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive, action: { showDeleteAlert = true }) {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .alert("Eliminar Colección", isPresented: $showDeleteAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    if collectionManager.deleteCollection(collection) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text("¿Estás seguro de que quieres eliminar '\(collection.name)'?")
            }
        }
    }
}

// 5. ReviewRowView
struct ReviewRowView: View {
    let review: Review
    let comic: Comic
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let imageName = comic.localImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 90)
                        .cornerRadius(8)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 90)
                        .overlay(
                            Image(systemName: "book.closed")
                                .foregroundColor(.white.opacity(0.5))
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(comic.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(review.title)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack {
                        StarRatingView(rating: .constant(review.rating), editable: false, size: 14)
                        
                        Spacer()
                        
                        Text(formatDate(review.createdDate))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Text(review.content.prefix(100) + (review.content.count > 100 ? "..." : ""))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                .padding(.leading, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            showDetail = true
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// 6. ReviewDetailView
struct ReviewDetailView: View {
    let review: Review
    let comic: Comic
    @ObservedObject var reviewManager: ReviewManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showEditReview = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header con portada
                    HStack(spacing: 16) {
                        if let imageName = comic.localImageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 150)
                                .cornerRadius(8)
                                .clipped()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(comic.title)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Issue \(comic.issue)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            StarRatingView(rating: .constant(review.rating), editable: false, size: 20)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    // Contenido de la reseña
                    VStack(alignment: .leading, spacing: 16) {
                        Text(review.title)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text(review.content)
                            .font(.body)
                            .foregroundColor(.white)
                            .lineSpacing(4)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        HStack {
                            Text("Creada: \(formatDate(review.createdDate))")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if let modifiedDate = review.lastModified {
                                Spacer()
                                Text("Editada: \(formatDate(modifiedDate))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Reseña")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { showEditReview = true }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: { showDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("Eliminar Reseña", isPresented: $showDeleteAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    reviewManager.deleteReview(review)
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("¿Estás seguro de que quieres eliminar esta reseña?")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// 7. EditProfileView
struct EditProfileView: View {
    @ObservedObject var userManager: UserManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var email = ""
    
    init(userManager: UserManager) {
        self.userManager = userManager
        _name = State(initialValue: userManager.currentUser.name)
        _email = State(initialValue: userManager.currentUser.email)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información Personal")) {
                    TextField("Nombre", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button(action: saveProfile) {
                        HStack {
                            Spacer()
                            Text("Guardar Cambios")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        userManager.updateUser(name: name, email: email)
        presentationMode.wrappedValue.dismiss()
    }
}

// 8. AddReviewView
struct AddReviewView: View {
    let comic: Comic
    @ObservedObject var reviewManager: ReviewManager
    var existingReview: Review?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var rating = 5
    @State private var title = ""
    @State private var content = ""
    
    init(comic: Comic, reviewManager: ReviewManager, existingReview: Review? = nil) {
        self.comic = comic
        self.reviewManager = reviewManager
        self.existingReview = existingReview
        
        if let review = existingReview {
            _rating = State(initialValue: review.rating)
            _title = State(initialValue: review.title)
            _content = State(initialValue: review.content)
        }
    }
    
    var isEditing: Bool {
        existingReview != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Calificación")) {
                    HStack {
                        Spacer()
                        StarRatingView(rating: $rating, editable: true, size: 30)
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Título")) {
                    TextField("Título de la reseña", text: $title)
                }
                
                Section(header: Text("Contenido")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section {
                    Button(action: saveReview) {
                        HStack {
                            Spacer()
                            Text(isEditing ? "Actualizar Reseña" : "Publicar Reseña")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle(isEditing ? "Editar Reseña" : "Nueva Reseña")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveReview() {
        if let existingReview = existingReview {
            // Actualizar reseña existente
            _ = reviewManager.updateReview(
                existingReview,
                rating: rating,
                title: title,
                content: content
            )
        } else {
            // Crear nueva reseña
            _ = reviewManager.createReview(
                comicID: comic.id,
                rating: rating,
                title: title,
                content: content
            )
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// 9. AddComicsToCollectionView
struct AddComicsToCollectionView: View {
    let collection: Collection
    @ObservedObject var collectionManager: CollectionManager
    @ObservedObject var comicManager: ComicManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedComics: Set<UUID> = []
    
    var allComics: [Comic] {
        tendenciasComicsBase + nuevosComicsBase + comicManager.userComics
    }
    
    init(collection: Collection, collectionManager: CollectionManager, comicManager: ComicManager) {
        self.collection = collection
        self.collectionManager = collectionManager
        self.comicManager = comicManager
        _selectedComics = State(initialValue: Set(collection.comicIDs))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allComics) { comic in
                    HStack {
                        if let imageName = comic.localImageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 75)
                                .cornerRadius(4)
                                .clipped()
                        } else {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 75)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(comic.title)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text("Issue \(comic.issue) • \(comic.year)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: selectedComics.contains(comic.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedComics.contains(comic.id) ? .blue : .gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleSelection(for: comic.id)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Añadir a \(collection.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func toggleSelection(for comicID: UUID) {
        if selectedComics.contains(comicID) {
            selectedComics.remove(comicID)
        } else {
            selectedComics.insert(comicID)
        }
    }
    
    private func saveChanges() {
        _ = collectionManager.updateCollection(
            collection,
            comicIDs: Array(selectedComics)
        )
        presentationMode.wrappedValue.dismiss()
    }
}

// 10. ComicReaderView
struct ComicReaderView: View {
    let comic: Comic
    @ObservedObject var comicManager: ComicManager
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0
    
    var body: some View {
        NavigationView {
            VStack {
                if let pdfFileName = comic.pdfFileName,
                   let pdfURL = Bundle.main.url(forResource: pdfFileName, withExtension: nil) {
                    PDFKitView(url: pdfURL)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Cómic no disponible")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("El archivo PDF no está disponible para este cómic")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .navigationTitle(comic.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// Vista para mostrar PDFs
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // No es necesario actualizar la vista
    }
}

// MARK: - FeatureRow para StoreView
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - Main Views

// MARK: - StoreView con Stripe Integration
struct StoreView: View {
    @ObservedObject var userManager: UserManager
    @ObservedObject var coinManager: CoinManager
    @Binding var showDrawer: Bool
    @StateObject private var stripeManager = StripeManager.shared
    
    @State private var showPurchaseSuccess = false
    @State private var purchasedPackage: CoinPackage?
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    @State private var snackbarType = ""
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Header con balance
                    VStack(spacing: 16) {
                        CoinBadgeView(coins: userManager.currentUser.coins, size: 24)
                            .scaleEffect(1.2)
                        
                        Text("Tienda de Monedas")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Compra monedas para desbloquear portadas y cómics exclusivos")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    
                    // Paquetes de monedas
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Paquetes Disponibles")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(coinManager.availablePackages) { package in
                                CoinPackageCard(package: package) {
                                    initiatePurchase(package)
                                }
                                .disabled(stripeManager.isProcessing)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Información de precios
                    VStack(alignment: .leading, spacing: 16) {
                        Text("¿Para qué sirven las monedas?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            FeatureRow(
                                icon: "photo.fill",
                                title: "Descargar Portadas",
                                description: "10-20 monedas por portada HD",
                                color: .blue
                            )
                            
                            FeatureRow(
                                icon: "book.fill",
                                title: "Descargar Cómics",
                                description: "Próximamente: 50 monedas por cómic completo",
                                color: .purple
                            )
                            
                            FeatureRow(
                                icon: "crown.fill",
                                title: "Contenido Exclusivo",
                                description: "Acceso a cómics raros y ediciones especiales",
                                color: .yellow
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    
                    // Nota sobre Stripe
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .font(.title2 )
                                .foregroundColor(.purple )
                            
                            Text("Sistema de Pago Seguro")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Text("Usamos Stripe para procesar pagos de forma segura. Todas las transacciones están encriptadas y protegidas.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                            
                            Text("Pago 100% seguro con cifrado SSL")
                                .font(.caption2)
                                .foregroundColor(.green)
                            
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            .background(Color.black.ignoresSafeArea())
            
            // Overlay para cerrar drawer
            if showDrawer {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showDrawer = false
                        }
                    }
            }
            
            // Payment Sheet de Stripe
            if let paymentSheet = stripeManager.paymentSheet {
                PaymentSheetWrapper(
                    paymentSheet: paymentSheet,
                    isPresented: Binding(
                        get: { stripeManager.paymentSheet != nil },
                        set: { if !$0 { stripeManager.paymentSheet = nil } }
                    ),
                    onCompletion: stripeManager.onPaymentCompletion
                )
            }
            
            // Modal de compra exitosa
            if showPurchaseSuccess, let package = purchasedPackage {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showPurchaseSuccess = false
                    }
                
                VStack(spacing: 25) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.green)
                    
                    Text("¡Compra Exitosa!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        Text("+\(package.coins) monedas")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.yellow)
                        
                        Text("Paquete \(package.name)")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    
                    Text("Ahora tienes \(userManager.currentUser.coins) monedas disponibles")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        showPurchaseSuccess = false
                    }) {
                        Text("Continuar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding(30)
                .background(Color(.systemGray5))
                .cornerRadius(30)
                .padding(.horizontal, 30)
                .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 20)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showPurchaseSuccess)
            }
            
            SnackbarView(
                message: snackbarMessage,
                type: snackbarType,
                isShowing: $showSnackbar
            )
        }
        .navigationTitle("Tienda")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CircleAvatarView(size: 36) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showDrawer.toggle()
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .paymentCompleted)) { _ in
            if let package = purchasedPackage {
                completePurchase(package)
            }
        }
    }
    
    private func initiatePurchase(_ package: CoinPackage) {
        purchasedPackage = package
        
        stripeManager.preparePaymentSheet(for: package) { success in
            if !success {
                showSnackbar(message: "Error al preparar el pago. Intenta nuevamente.", type: "error")
                purchasedPackage = nil
            }
        }
    }
    
    private func completePurchase(_ package: CoinPackage) {
        userManager.simulatePurchase(package: package)
        purchasedPackage = package
        showPurchaseSuccess = true
        showSnackbar(message: "¡Compra realizada! +\(package.coins) monedas añadidas", type: "success")
    }
    
    private func showSnackbar(message: String, type: String) {
        snackbarMessage = message
        snackbarType = type
        showSnackbar = true
    }
}

// Wrapper para PaymentSheet
struct PaymentSheetWrapper: UIViewControllerRepresentable {
    let paymentSheet: PaymentSheet
    @Binding var isPresented: Bool
    let onCompletion: (PaymentSheetResult) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            paymentSheet.present(from: controller) { result in
                onCompletion(result)
                isPresented = false
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ComicCatalogView: View {
    @ObservedObject var comicManager: ComicManager
    @ObservedObject var userManager: UserManager
    @ObservedObject var reviewManager: ReviewManager // UPDATE: Added ReviewManager dependency
    @Binding var showDrawer: Bool
    @State private var searchText: String = ""
    @State private var showAddComic = false
    @State private var selectedComic: Comic?
    
    var allComics: [Comic] {
        tendenciasComicsBase + nuevosComicsBase + comicManager.userComics
    }
    
    var filteredSections: [ComicSection] {
        let comics = allComics
        
        if searchText.isEmpty {
            let dcComics = comics.filter { $0.franchise == "DC" }
            let marvelComics = comics.filter { $0.franchise == "Marvel" }
            let transformersComics = comics.filter { $0.franchise == "IDW" }
            let spawnComics = comics.filter { $0.franchise == "Image" }
            let userComics = comics.filter { $0.isUserAdded }
            
            var sections: [ComicSection] = []
            
            if !userComics.isEmpty {
                sections.append(ComicSection(title: "Mis Cómics", comics: userComics))
            }
            
            sections.append(contentsOf: [
                ComicSection(title: "DC Comics", comics: dcComics),
                ComicSection(title: "Marvel", comics: marvelComics),
                ComicSection(title: "Transformers", comics: transformersComics),
                ComicSection(title: "Spawn", comics: spawnComics),
                ComicSection(title: "Recomendados", comics: Array(comics.shuffled().prefix(15)))
            ])
            
            return sections
        } else {
            let lowercased = searchText.lowercased()
            let filtered = comics.filter {
                $0.title.lowercased().contains(lowercased) ||
                $0.issue.lowercased().contains(lowercased) ||
                $0.franchise.lowercased().contains(lowercased)
            }
            return filtered.isEmpty ? [] : [ComicSection(title: "Resultados", comics: filtered)]
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                if filteredSections.isEmpty && !searchText.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No se encontraron resultados")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Intenta con otros términos de búsqueda")
                            .font(.body)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(height: 400)
                } else {
                    LazyVStack(alignment: .leading, spacing: 32) {
                        ForEach(filteredSections) { section in
                            ComicSectionView(section: section, selectedComic: $selectedComic)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .background(Color.black.ignoresSafeArea())
            
            if showDrawer {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showDrawer = false
                        }
                    }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Catálogo de Cómics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    NavigationLink(destination: StoreView(
                        userManager: userManager,
                        coinManager: CoinManager(),
                        showDrawer: $showDrawer
                    )) {
                        CoinBadgeView(coins: userManager.currentUser.coins, size: 14)
                    }
                    
                    Button(action: { showAddComic = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    CircleAvatarView(size: 36) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showDrawer.toggle()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddComic) {
            AddComicView(comicManager: comicManager)
        }
        .sheet(item: $selectedComic) { comic in
            ComicDetailView(
                comic: comic,
                comicManager: comicManager,
                userManager: userManager,
                reviewManager: reviewManager // UPDATE: Passing shared manager
            )
        }
    }
}

struct CollectionsView: View {
    @ObservedObject var collectionManager: CollectionManager
    @ObservedObject var comicManager: ComicManager
    @ObservedObject var userManager: UserManager
    @Binding var showDrawer: Bool
    @State private var showAddCollection = false
    @State private var selectedCollection: Collection?
    
    var body: some View {
        ZStack {
            ScrollView {
                if collectionManager.collections.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No hay colecciones")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Crea tu primera colección para organizar tus cómics")
                            .font(.body)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(height: 400)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(collectionManager.collections) { collection in
                            Button(action: {
                                selectedCollection = collection
                            }) {
                                CollectionCardView(collection: collection)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .background(Color.black.ignoresSafeArea())
            
            if showDrawer {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showDrawer = false
                        }
                    }
            }
        }
        .navigationTitle("Colecciones")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    NavigationLink(destination: StoreView(
                        userManager: userManager,
                        coinManager: CoinManager(),
                        showDrawer: $showDrawer
                    )) {
                        CoinBadgeView(coins: userManager.currentUser.coins, size: 14)
                    }
                    
                    Button(action: { showAddCollection = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    CircleAvatarView(size: 36) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showDrawer.toggle()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddCollection) {
            AddCollectionView(collectionManager: collectionManager)
        }
        .sheet(item: $selectedCollection) { collection in
            CollectionDetailView(
                collection: collection,
                collectionManager: collectionManager,
                comicManager: comicManager
            )
        }
    }
}

struct ReviewsView: View {
    @ObservedObject var reviewManager: ReviewManager
    @ObservedObject var comicManager: ComicManager
    @ObservedObject var userManager: UserManager
    @Binding var showDrawer: Bool
    @State private var selectedReview: Review?
    
    var reviews: [Review] {
        reviewManager.reviews
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                if reviews.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No hay reseñas")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Escribe tu primera reseña para un cómic")
                            .font(.body)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(height: 400)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(reviews) { review in
                            if let comic = comicManager.userComics.first(where: { $0.id == review.comicID }) {
                                Button(action: {
                                    selectedReview = review
                                }) {
                                    ReviewRowView(review: review, comic: comic)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.black.ignoresSafeArea())
            
            if showDrawer {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showDrawer = false
                        }
                    }
            }
        }
        .navigationTitle("Mis Reseñas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    NavigationLink(destination: StoreView(
                        userManager: userManager,
                        coinManager: CoinManager(),
                        showDrawer: $showDrawer
                    )) {
                        CoinBadgeView(coins: userManager.currentUser.coins, size: 14)
                    }
                    
                    CircleAvatarView(size: 36) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showDrawer.toggle()
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedReview) { review in
            if let comic = comicManager.userComics.first(where: { $0.id == review.comicID }) {
                ReviewDetailView(
                    review: review,
                    comic: comic,
                    reviewManager: reviewManager
                )
            }
        }
    }
}

// StatCardView para ProfileView
struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var icon: String {
        switch transaction.type {
        case "reward", "purchase": return "plus.circle.fill"
        case "spend", "download_cover", "download_comic": return "minus.circle.fill"
        default: return "arrow.left.arrow.right.circle.fill"
        }
    }
    
    var color: Color {
        switch transaction.type {
        case "reward", "purchase": return .green
        case "spend", "download_cover", "download_comic": return .red
        default: return .gray
        }
    }
    
    var prefix: String {
        transaction.amount > 0 ? "+" : ""
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if let comicTitle = transaction.comicTitle {
                    Text(comicTitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(formatDate(transaction.date))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(prefix)\(transaction.amount)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(transaction.amount > 0 ? .green : .red)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct PurchasedCoverCard: View {
    let comic: Comic
    let imageName: String
    @State private var showDetail = false
    
    var body: some View {
        Button(action: { showDetail = true }) {
            VStack(spacing: 8) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 150)
                    .cornerRadius(8)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green.opacity(0.5), lineWidth: 2)
                    )
                
                Text(comic.title)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(width: 100)
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    
                    Text("Comprada")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                
                Text(comic.title)
                    .font(.title)
                    .bold()
                    .padding()
                
                Text("Issue: \(comic.issue)")
                Text("Año: \(comic.year)")
                Text("Franquicia: \(comic.franchise)")
                
                Spacer()
                
                Button("Cerrar") {
                    showDetail = false
                }
                .padding()
            }
            .padding()
        }
    }
}

struct ProfileView: View {
    @ObservedObject var userManager: UserManager
    @ObservedObject var comicManager: ComicManager
    @ObservedObject var collectionManager: CollectionManager
    @ObservedObject var reviewManager: ReviewManager
    @Binding var showDrawer: Bool
    @State private var showEditProfile = false
    @State private var showTransactions = false
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    @State private var snackbarType = ""
    
    var recentTransactions: [Transaction] {
        Array(userManager.currentUser.transactions.prefix(10))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        CircleAvatarView(size: 120) {}
                        
                        VStack(spacing: 8) {
                            Text(userManager.currentUser.name)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text(userManager.currentUser.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("Miembro desde \(formatDate(userManager.currentUser.joinedDate))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Balance de monedas
                    VStack(spacing: 16) {
                        Text("Monedas Disponibles")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        CoinBadgeView(coins: userManager.currentUser.coins, size: 28)
                        
                        NavigationLink(destination: StoreView(
                            userManager: userManager,
                            coinManager: CoinManager(),
                            showDrawer: $showDrawer
                        )) {
                            Text("Comprar Más Monedas")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    // Estadísticas
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Estadísticas")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCardView(
                                title: "Cómics",
                                value: "\(comicManager.userComics.count)",
                                icon: "book.fill",
                                color: .blue
                            )
                            
                            StatCardView(
                                title: "Colecciones",
                                value: "\(collectionManager.collections.filter { $0.isUserCreated }.count)",
                                icon: "folder.fill",
                                color: .green
                            )
                            
                            StatCardView(
                                title: "Reseñas",
                                value: "\(reviewManager.reviews.count)",
                                icon: "star.fill",
                                color: .yellow
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Portadas compradas
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Portadas Compradas")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(userManager.currentUser.purchasedCovers.count)")
                                .font(.headline)
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal)
                        
                        if userManager.currentUser.purchasedCovers.isEmpty {
                            Text("Aún no has comprado ninguna portada")
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 12) {
                                    ForEach(userManager.currentUser.purchasedCovers.prefix(10), id: \.self) { comicID in
                                        if let comic = (comicManager.userComics + tendenciasComicsBase + nuevosComicsBase).first(where: { $0.id == comicID }),
                                           let imageName = comic.localImageName {
                                            PurchasedCoverCard(comic: comic, imageName: imageName)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Historial de transacciones
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Historial Reciente")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { showTransactions = true }) {
                                Text("Ver Todo")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if recentTransactions.isEmpty {
                            Text("No hay transacciones recientes")
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(recentTransactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
            }
            .background(Color.black.ignoresSafeArea())
            
            if showDrawer {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showDrawer = false
                        }
                    }
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button("Editar") {
                        showEditProfile = true
                    }
                    
                    CircleAvatarView(size: 36) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showDrawer.toggle()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(userManager: userManager)
        }
        .overlay(
            SnackbarView(
                message: snackbarMessage,
                type: snackbarType,
                isShowing: $showSnackbar
            )
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

struct TransactionsView: View {
    let transactions: [Transaction]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                if transactions.isEmpty {
                    Text("No hay transacciones")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
            .navigationTitle("Historial de Transacciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ComicDetailView: View {
    let comic: Comic
    @ObservedObject var comicManager: ComicManager
    @ObservedObject var userManager: UserManager
    // UPDATE: Changed to ObservedObject to share state instead of creating a new one
    @ObservedObject var reviewManager: ReviewManager
    @Environment(\.presentationMode) var presentationMode
    // Note: CollectionManager is still local (@StateObject), could be refactored similarly if needed
    @StateObject private var collectionManager = CollectionManager()
    
    @State private var showReader = false
    @State private var showDeleteAlert = false
    @State private var showAddReview = false
    @State private var showAddToCollection = false
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    @State private var snackbarType = ""
    @State private var showPurchaseCoins = false
    @State private var showDownloadSuccess = false
    
    var userReview: Review? {
        reviewManager.getReviewsForComic(comic.id).first
    }
    
    var isFavorite: Bool {
        userManager.isFavorite(comicID: comic.id)
    }
    
    var hasPurchasedCover: Bool {
        userManager.hasPurchasedCover(for: comic.id)
    }
    
    var hasPurchasedComic: Bool {
        userManager.hasPurchasedComic(for: comic.id)
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Portada
                        if let imageName = comic.localImageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 400)
                                .cornerRadius(12)
                                .shadow(radius: 10)
                                .overlay(
                                    hasPurchasedCover ?
                                    AnyView(
                                        ZStack {
                                            Color.black.opacity(0.3)
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.green)
                                        }
                                            .cornerRadius(12)
                                    ) :
                                        AnyView(EmptyView())
                                )
                        } else {
                            Color.blue.opacity(0.3)
                                .frame(height: 400)
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Header with actions
                            HStack {
                                Text(comic.title)
                                    .font(.title)
                                    .bold()
                                
                                Spacer()
                                
                                Button(action: {
                                    userManager.toggleFavorite(comicID: comic.id)
                                    showSnackbar(message: isFavorite ? "Añadido a favoritos" : "Removido de favoritos", type: "success")
                                }) {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(isFavorite ? .red : .gray)
                                }
                            }
                            
                            // Basic info
                            HStack {
                                Label(comic.franchise, systemImage: "building.2")
                                Spacer()
                                Label(comic.year, systemImage: "calendar")
                                Spacer()
                                Label(comic.issue, systemImage: "number")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            
                            Divider()
                            
                            // Créditos
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Guionista: \(comic.writer)", systemImage: "pencil.circle.fill")
                                Label("Artista: \(comic.artist)", systemImage: "paintpalette.fill")
                            }
                            .font(.callout)
                            
                            // User review if exists
                            if let review = userReview {
                                VStack(alignment: .leading, spacing: 8) {
                                    Divider()
                                    
                                    HStack {
                                        Text("Tu Reseña")
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        StarRatingView(rating: .constant(review.rating), editable: false, size: 16)
                                    }
                                    
                                    Text(review.title)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    Text(review.content.prefix(100) + "...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                            }
                            
                            // Descripción
                            Text("Una obra maestra del cómic que ha dejado huella en la historia. Disfruta de esta edición especial.")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            
                            // Botones de descarga
                            VStack(spacing: 12) {
                                // Descargar Portada
                                DownloadButtonView(
                                    title: "Descargar Portada",
                                    icon: "photo.fill",
                                    price: hasPurchasedCover ? nil : comic.coverPrice,
                                    isPurchased: hasPurchasedCover,
                                    action: {
                                        if hasPurchasedCover {
                                            // Ya comprada, mostrar mensaje
                                            showSnackbar(message: "Ya has descargado esta portada", type: "info")
                                        } else if let price = comic.coverPrice {
                                            if userManager.currentUser.coins >= price {
                                                // Comprar portada
                                                if userManager.spendCoins(price, comic: comic, type: "download_cover") {
                                                    showSnackbar(message: "¡Portada descargada! -\(price) monedas", type: "success")
                                                    showDownloadSuccess = true
                                                }
                                            } else {
                                                // No hay suficientes monedas
                                                showSnackbar(message: "Monedas insuficientes. Necesitas \(price) monedas", type: "error")
                                                showPurchaseCoins = true
                                            }
                                        }
                                    }
                                )
                                
                                // Descargar Cómic (placeholder para futuro)
                                DownloadButtonView(
                                    title: "Descargar Cómic Completo",
                                    icon: "book.fill",
                                    price: comic.comicPrice,
                                    isPurchased: false,
                                    action: {
                                        showSnackbar(message: "Próximamente: Descarga de cómics completos", type: "info")
                                    }
                                )
                                
                                // Botones existentes
                                if comic.pdfFileName != nil {
                                    Button(action: { showReader = true }) {
                                        Label("Leer Cómic", systemImage: "book.fill")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(
                                                LinearGradient(
                                                    colors: [.red, .red.opacity(0.8)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    Button(action: { showAddReview = true }) {
                                        Label(userReview == nil ? "Escribir Reseña" : "Editar Reseña", systemImage: "star.fill")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .cornerRadius(12)
                                    }
                                    
                                    Button(action: { showAddToCollection = true }) {
                                        Label("Añadir a Colección", systemImage: "folder.badge.plus")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.green.opacity(0.2))
                                            .foregroundColor(.green)
                                            .cornerRadius(12)
                                    }
                                }
                                
                                if comic.isUserAdded {
                                    Button(action: { showDeleteAlert = true }) {
                                        Label("Eliminar Cómic", systemImage: "trash.fill")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.red.opacity(0.2))
                                            .foregroundColor(.red)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.top)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .background(Color.black.ignoresSafeArea())
                .navigationTitle("Detalles")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cerrar") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        CoinBadgeView(coins: userManager.currentUser.coins, size: 14)
                    }
                }
                .sheet(isPresented: $showAddReview) {
                    AddReviewView(
                        comic: comic,
                        reviewManager: reviewManager,
                        existingReview: userReview
                    )
                }
                .sheet(isPresented: $showAddToCollection) {
                    AddComicsToCollectionView(
                        collection: Collection(name: "Seleccionar colección..."),
                        collectionManager: collectionManager,
                        comicManager: comicManager
                    )
                }
                .sheet(isPresented: $showReader) {
                    ComicReaderView(comic: comic, comicManager: comicManager)
                }
                .sheet(isPresented: $showPurchaseCoins) {
                    StoreView(
                        userManager: userManager,
                        coinManager: CoinManager(),
                        showDrawer: .constant(false)
                    )
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Eliminar Cómic"),
                        message: Text("¿Estás seguro de que quieres eliminar '\(comic.title)'?"),
                        primaryButton: .destructive(Text("Eliminar")) {
                            comicManager.deleteComic(comic)
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            
            SnackbarView(
                message: snackbarMessage,
                type: snackbarType,
                isShowing: $showSnackbar
            )
            
            // Modal de descarga exitosa
            if showDownloadSuccess {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showDownloadSuccess = false
                    }
                
                VStack(spacing: 25) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.green)
                    
                    Text("¡Portada Descargada!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("La portada de '\(comic.title)' ha sido añadida a tu colección.")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    if let imageName = comic.localImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showDownloadSuccess = false
                    }) {
                        Text("Continuar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding(30)
                .background(Color(.systemGray5))
                .cornerRadius(30)
                .padding(.horizontal, 30)
                .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 20)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showDownloadSuccess)
            }
        }
    }
    
    private func showSnackbar(message: String, type: String) {
        snackbarMessage = message
        snackbarType = type
        showSnackbar = true
    }
}

// MARK: - ComicSectionView
struct ComicSectionView: View {
    let section: ComicSection
    @Binding var selectedComic: Comic?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(section.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(section.comics.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(section.comics) { comic in
                        EnhancedComicCardView(
                            comic: comic,
                            width: 120,
                            height: 180,
                            showDetail: {
                                selectedComic = comic
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Main App View
struct ContentView: View {
    @StateObject private var comicManager = ComicManager()
    @StateObject private var collectionManager = CollectionManager()
    @StateObject private var reviewManager = ReviewManager()
    @StateObject private var userManager = UserManager()
    @StateObject private var coinManager = CoinManager()
    
    @State private var selectedView = "catalog"
    @State private var showDrawer = false
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    @State private var snackbarType = ""
    
    var body: some View {
        ZStack {
            NavigationView {
                Group {
                    switch selectedView {
                    case "catalog":
                        ComicCatalogView(
                            comicManager: comicManager,
                            userManager: userManager,
                            reviewManager: reviewManager, // UPDATE: Pass dependency
                            showDrawer: $showDrawer
                        )
                    case "myComics":
                        ComicCatalogView(
                            comicManager: comicManager,
                            userManager: userManager,
                            reviewManager: reviewManager, // UPDATE: Pass dependency
                            showDrawer: $showDrawer
                        )
                    case "collections":
                        CollectionsView(
                            collectionManager: collectionManager,
                            comicManager: comicManager,
                            userManager: userManager,
                            showDrawer: $showDrawer
                        )
                    case "reviews":
                        ReviewsView(
                            reviewManager: reviewManager,
                            comicManager: comicManager,
                            userManager: userManager,
                            showDrawer: $showDrawer
                        )
                    case "profile":
                        ProfileView(
                            userManager: userManager,
                            comicManager: comicManager,
                            collectionManager: collectionManager,
                            reviewManager: reviewManager,
                            showDrawer: $showDrawer
                        )
                    case "store":
                        StoreView(
                            userManager: userManager,
                            coinManager: coinManager,
                            showDrawer: $showDrawer
                        )
                    default:
                        ComicCatalogView(
                            comicManager: comicManager,
                            userManager: userManager,
                            reviewManager: reviewManager, // UPDATE: Pass dependency
                            showDrawer: $showDrawer
                        )
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text(navigationTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
            SnackbarView(
                message: snackbarMessage,
                type: snackbarType,
                isShowing: $showSnackbar
            )
            
            DrawerMenuView(
                isShowing: $showDrawer,
                selectedView: $selectedView,
                userProfile: userManager.currentUser,
                onLogout: {
                    userManager.logout()
                }
            )
        }
        .preferredColorScheme(.dark)
    }
    
    var navigationTitle: String {
        switch selectedView {
        case "catalog": return "Catálogo de Cómics"
        case "myComics": return "Mis Cómics"
        case "collections": return "Colecciones"
        case "reviews": return "Reseñas"
        case "profile": return "Perfil"
        case "store": return "Tienda"
        default: return "Catálogo de Cómics"
        }
    }
}

// MARK: - App Entry
struct ComicCatalogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
