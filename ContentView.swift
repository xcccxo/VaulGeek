import SwiftUI
import PDFKit

struct Comic: Identifiable {
    let id = UUID()
    let title: String
    let issue: String
    let year: String
    let coverURL: URL?
    let localImageName: String?
    let franchise: String
    let writer: String
    let artist: String
    let pdfFileName: String?
}

struct ComicSection: Identifiable {
    let id = UUID()
    let title: String
    let comics: [Comic]
}

// PDFKit View
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.pageShadowsEnabled = false
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - Datos de ejemplo
let tendenciasComicsBase: [Comic] = [
    Comic(title: "All-Star Superman", issue: "#1", year: "2005", coverURL: nil, localImageName: "ASS", franchise: "DC", writer: "Grant Morrison", artist: "Frank Quitely", pdfFileName: nil),
    Comic(title: "The Death of Superman", issue: "#75", year: "1993", coverURL: nil, localImageName: "Supermán", franchise: "DC", writer: "Dan Jurgens", artist: "Brett Breeding", pdfFileName: nil),
    Comic(title: "Absolute Batman", issue: "#6", year: "2025", coverURL: nil, localImageName: "Batman2", franchise: "DC", writer: "Tini Howard", artist: "Mikel Janin", pdfFileName: nil),
    Comic(title: "Batman: The Dark Knight Returns", issue: "#1", year: "1986", coverURL: nil, localImageName: "Batman3", franchise: "DC", writer: "Frank Miller", artist: "Frank Miller", pdfFileName: "dark_knight_returns.pdf"),
    Comic(title: "The Batman Who Laughs", issue: "#1", year: "2017", coverURL: nil, localImageName: "BWL", franchise: "DC", writer: "Scott Snyder", artist: "Jock", pdfFileName: nil),
    Comic(title: "Spawn/Batman", issue: "One-Shot", year: "1994", coverURL: nil, localImageName: "SB", franchise: "Image", writer: "Frank Miller", artist: "Todd McFarlane", pdfFileName: nil),
    Comic(title: "Spawn", issue: "#1", year: "1992", coverURL: nil, localImageName: "Spawn", franchise: "Image", writer: "Todd McFarlane", artist: "Todd McFarlane", pdfFileName: nil),
    Comic(title: "Spawn", issue: "#285", year: "2018", coverURL: nil, localImageName: "Spawn.jpg", franchise: "Image", writer: "Todd McFarlane", artist: "Jason Shawn Alexander", pdfFileName: nil),
    Comic(title: "Spawn", issue: "#97", year: "2000", coverURL: nil, localImageName: "Ángela", franchise: "Image", writer: "Brian Wood", artist: "Ashley Wood", pdfFileName: nil),
    Comic(title: "Transformers", issue: "#12", year: "2024", coverURL: nil, localImageName: "TF2", franchise: "IDW", writer: "Robbie Robbins", artist: "Josh Burcham", pdfFileName: nil),
    Comic(title: "Transformers", issue: "#18", year: "2025", coverURL: nil, localImageName: "TF5", franchise: "IDW", writer: "Simon Furman", artist: "Don Figueroa", pdfFileName: nil),
    Comic(title: "Transformers", issue: "#16", year: "2025", coverURL: nil, localImageName: "Meg", franchise: "IDW", writer: "Jody Houser", artist: "Marco Cicirello", pdfFileName: nil),
    Comic(title: "Transformers", issue: "#22", year: "2025", coverURL: nil, localImageName: "TF3", franchise: "IDW", writer: "Brian Ruckley", artist: "Anna Malkova", pdfFileName: nil),
    Comic(title: "Transformers", issue: "#8", year: "2024", coverURL: nil, localImageName: "TF4", franchise: "IDW", writer: "Brandon Easton", artist: "Jack Lawrence", pdfFileName: nil)
]

let nuevosComicsBase: [Comic] = [
    Comic(title: "X-Men (Vol. 2)", issue: "#1", year: "1991", coverURL: nil, localImageName: "Magneto", franchise: "Marvel", writer: "Chris Claremont", artist: "Jim Lee", pdfFileName: nil),
    Comic(title: "The Amazing Spider-Man", issue: "#43", year: "2002", coverURL: nil, localImageName: "SPM", franchise: "Marvel", writer: "J. Michael Straczynski", artist: "John Romita Jr.", pdfFileName: nil),
    Comic(title: "Psylocke", issue: "#1", year: "2024", coverURL: nil, localImageName: "Psy2", franchise: "Marvel", writer: "Tini Howard", artist: "Marco Checchetto", pdfFileName: nil),
    Comic(title: "Psylocke", issue: "#7", year: "2025", coverURL: nil, localImageName: "Psy", franchise: "Marvel", writer: "Gerry Duggan", artist: "Russell Dauterman", pdfFileName: nil),
    Comic(title: "Hulk", issue: "#9", year: "2022", coverURL: nil, localImageName: "Jolk", franchise: "Marvel", writer: "Donny Cates", artist: "Ryan Ottley", pdfFileName: nil),
    Comic(title: "Web of Spider-Man", issue: "#32", year: "1987", coverURL: nil, localImageName: "SPM2", franchise: "Marvel", writer: "Roger Stern", artist: "Todd McFarlane", pdfFileName: nil),
    Comic(title: "Magik", issue: "#3", year: "2025", coverURL: nil, localImageName: "Magik", franchise: "Marvel", writer: "Vita Ayala", artist: "Rod Reis", pdfFileName: nil),
    Comic(title: "The Infinity Gauntlet", issue: "#1", year: "1991", coverURL: nil, localImageName: "Tunas", franchise: "Marvel", writer: "Jim Starlin", artist: "George Pérez", pdfFileName: nil),
    Comic(title: "Transformers 84", issue: "#1", year: "2020", coverURL: nil, localImageName: "TF7", franchise: "IDW", writer: "Simon Furman", artist: "Guido Guidi", pdfFileName: nil),
    Comic(title: "Grimlock", issue: "#1", year: "2022", coverURL: nil, localImageName: "Grimlock", franchise: "IDW", writer: "Daniel Warren Johnson", artist: "Daniel Warren Johnson", pdfFileName: nil),
    Comic(title: "Transformers", issue: "#11", year: "2024", coverURL: nil, localImageName: "TF8", franchise: "IDW", writer: "Nick Roche", artist: "Nick Roche", pdfFileName: nil),
    Comic(title: "Transformers", issue: "#5", year: "2024", coverURL: nil, localImageName: "TF9", franchise: "IDW", writer: "James Roberts", artist: "Alex Milne", pdfFileName: nil),
    Comic(title: "Transformers 84", issue: "#23", year: "2023", coverURL: nil, localImageName: "TF6", franchise: "IDW", writer: "Chris Ryall", artist: "Andrew Wildman", pdfFileName: nil),
    Comic(title: "Transformers", issue: "#16", year: "2025", coverURL: nil, localImageName: "Bruticus", franchise: "IDW", writer: "Simon Furman", artist: "E.J. Su", pdfFileName: nil),
    Comic(title: "Energon Universe 2024", issue: "#1", year: "2024", coverURL: nil, localImageName: "Transformers1.jpg", franchise: "IDW", writer: "Robert Kirkman", artist: "Lorenzo De Felici", pdfFileName: nil)
]

// Datos Filtrados
let allComics = tendenciasComicsBase + nuevosComicsBase

let dcComics: [Comic] = allComics.filter { $0.franchise == "DC" }
let marvelComics: [Comic] = allComics.filter { $0.franchise == "Marvel" }
let transformersComics: [Comic] = allComics.filter { $0.franchise == "IDW" }
let spawnComics: [Comic] = allComics.filter { $0.franchise == "Image" }

let sampleComicSections: [ComicSection] = [
    ComicSection(title: "DC Comics", comics: dcComics),
    ComicSection(title: "Marvel", comics: marvelComics),
    ComicSection(title: "Transformers", comics: transformersComics),
    ComicSection(title: "Spawn", comics: spawnComics),
    ComicSection(title: "Recomendados", comics: Array(allComics.shuffled().prefix(15)))
]

// MARK: - Vista Principal
struct ContentView: View {
    @State private var searchText: String = ""
    
    var filteredSections: [ComicSection] {
        if searchText.isEmpty {
            return sampleComicSections
        } else {
            let lowercased = searchText.lowercased()
            let filtered = allComics.filter {
                $0.title.lowercased().contains(lowercased) ||
                $0.issue.lowercased().contains(lowercased) ||
                $0.franchise.lowercased().contains(lowercased)
            }
            return filtered.isEmpty ? [] : [ComicSection(title: "Resultados", comics: filtered)]
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if filteredSections.isEmpty && !searchText.isEmpty {
                    VStack {
                        Spacer()
                        Text("No se encontraron resultados")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                        Spacer()
                    }
                } else {
                    LazyVStack(alignment: .leading, spacing: 32) {
                        ForEach(filteredSections) { section in
                            ComicSectionView(section: section)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitle("Catálogo de Cómics", displayMode: .inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .background(Color.black.ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

struct ComicSectionView: View {
    let section: ComicSection
    
    // Dimensiones adaptativas
    var cardWidth: CGFloat {
        UIScreen.main.bounds.width > 700 ? 160 : 120
    }
    
    var cardHeight: CGFloat {
        UIScreen.main.bounds.width > 700 ? 240 : 180
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            // Altura mínima explícita para evitar recortes
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(section.comics) { comic in
                        ComicCardView(comic: comic, width: cardWidth, height: cardHeight)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4) // Padding vertical para evitar sombras cortadas
            }
            .frame(height: cardHeight + 60) // Altura fija = cardHeight + espacio para título
        }
    }
}

// Tarjeta de Cómic
struct ComicCardView: View {
    let comic: Comic
    @State private var showDetail = false
    let width: CGFloat
    let height: CGFloat
    @GestureState private var isPressing = false
    
    var body: some View {
        Button(action: { showDetail.toggle() }) {
            VStack(spacing: 8) {
                // Imagen del cómic
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                    
                    Group {
                        if let imageName = comic.localImageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                        } else {
                            placeholder
                        }
                    }
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(width: width, height: height)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
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
        .buttonStyle(.plain)
        .scaleEffect(isPressing ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressing)
        .simultaneousGesture( 
            LongPressGesture(minimumDuration: 0.001)
                .updating($isPressing) { value, state, _ in
                    state = value
                }
        )
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            ComicDetailView(comic: comic)
        }
    }
    
    var placeholder: some View {
        ZStack {
            Color.blue.opacity(0.3)
            VStack {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.5))
                Text(comic.title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(8)
            }
        }
    }
}

// Vista de Detalle
struct ComicDetailView: View {
    let comic: Comic
    @Environment(\.dismiss) var dismiss
    @State private var showReader = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Portada grande
                    if let imageName = comic.localImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 400)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    } else {
                        Color.blue.opacity(0.3)
                            .frame(height: 400)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(comic.title)
                            .font(.title)
                            .bold()
                        
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Guionista: \(comic.writer)", systemImage: "pencil.circle.fill")
                            Label("Artista: \(comic.artist)", systemImage: "paintpalette.fill")
                        }
                        .font(.callout)
                        
                        Text("Una obra maestra del cómic que ha dejado huella en la historia. Disfruta de esta edición especial.")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
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
                        .padding(.top)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Detalles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .sheet(isPresented: $showReader) {
                ComicReaderView(comic: comic)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Lector de Cómics
struct ComicReaderView: View {
    let comic: Comic
    @Environment(\.dismiss) var dismiss
    @State private var isBarsHidden = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let pdfName = comic.pdfFileName,
                   let url = Bundle.main.url(forResource: pdfName, withExtension: nil) {
                    PDFKitView(url: url)
                        .onTapGesture {
                            withAnimation {
                                isBarsHidden.toggle()
                            }
                        }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Lector no disponible")
                            .font(.title2)
                            .bold()
                        
                        Text(comic.pdfFileName != nil ?
                             "Archivo '\(comic.pdfFileName!)' no encontrado" :
                                "Este cómic aún no tiene PDF asignado")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                    }
                }
            }
            .navigationTitle(comic.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(isBarsHidden ? .hidden : .visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
