import Foundation
import UIKit  // 👈 AÑADE ESTO (para UIColor)
import Stripe  // 👈 Esto ya lo tienes, pero verifica que funcione
import StripePaymentSheet  // 👈 AÑADE ESTO (para PaymentSheet)

class StripeManager: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    @Published var isProcessing = false
    
    static let shared = StripeManager()
    static let backendURL = "http://10.100.9.67:3000"
    
    private init() {
        // Clave pública de prueba
        StripeAPI.defaultPublishableKey = "pk_test_51P6NLLRqM0uw0A2oHmJj9Q6XKvz7wY4L8t9fG6hT3sWqR1vN2l"
    }
    
    func preparePaymentSheet(for package: CoinPackage, completion: @escaping (Bool) -> Void) {
        isProcessing = true
        
        createPaymentIntent(amount: Int(package.price * 100), currency: "usd") { result in
            switch result {
            case .success(let clientSecret):
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "Comic Catalog"
                configuration.primaryButtonColor = UIColor.systemOrange
                configuration.allowsDelayedPaymentMethods = true
                
                DispatchQueue.main.async {
                    self.paymentSheet = PaymentSheet(
                        paymentIntentClientSecret: clientSecret,
                        configuration: configuration
                    )
                    self.isProcessing = false
                    completion(true)
                }
                
            case .failure(let error):
                print("❌ Error Stripe: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isProcessing = false
                    completion(false)
                }
            }
        }
    }
    
    func onPaymentCompletion(result: PaymentSheetResult) {
        self.paymentResult = result
        
        switch result {
        case .completed:
            print("✅ Pago completado!")
            NotificationCenter.default.post(name: .paymentCompleted, object: nil)
            
        case .canceled:
            print("❌ Pago cancelado por el usuario")
            
        case .failed(let error):
            print("⚠️ Error en pago: \(error.localizedDescription)")
        }
    }
    
    private func createPaymentIntent(amount: Int, currency: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(StripeManager.backendURL)/create-payment-intent") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let body: [String: Any] = ["amount": amount]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        print("🌐 Llamando al backend: \(url.absoluteString)")
        print("💰 Amount: \(amount) centavos ($\(Double(amount)/100.0))")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error de red: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    completion(.failure(NSError(domain: "No data", code: 0)))
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Respuesta: \(responseString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let clientSecret = json["clientSecret"] as? String {
                            print("✅ ClientSecret obtenido")
                            completion(.success(clientSecret))
                        } else if let errorMsg = json["error"] as? String {
                            print("❌ Error del backend: \(errorMsg)")
                            completion(.failure(NSError(domain: errorMsg, code: 0)))
                        } else {
                            print("⚠️ JSON inesperado: \(json)")
                            completion(.failure(NSError(domain: "Invalid response format", code: 0)))
                        }
                    }
                } catch {
                    print("❌ Error parsing JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

extension Notification.Name {
    static let paymentCompleted = Notification.Name("paymentCompleted")
}
